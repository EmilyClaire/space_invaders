;---------------------------------------------------------------------
                Setting Up

;---------------------------------------------------------------------
.DSEG
.ORG 0x00

.EQU VGA_HADD = 0x90        ;VGA Horizontal? Address
.EQU VGA_LADD = 0x91        ;VGA Vertical? Address
.EQU VGA_COLOR = 0x92       ;VGA Color Address

.equ END_ROW_SHIP = 0x4A; the row length minus 3 times 2
.equ END_ROW_PLAYER = 0x25
.equ END_COL = 0x1D
.equ SHIP_COLOR = 0xE3 ; pink
                  ;0x03 ; blue
                  ;0xE0 ; red
                  ;0x1C ; green
                  ;0xFC ; yellow 
                  ;0x1F ; aqua

.EQU PLAYER_COLOR = 0xFF ; white
.equ SHIP_BULLET_COLOR = 0x03 ; blue
.equ PLAYER_BULLET_COLOR = 0xFC ; yellow

.equ SHIP_BULLET_RATE = 0x0B


.EQU SHIP_X_LOC = 0x0C
.EQU SHIP_Y_LOC = 0x0A
.EQU SHIP_COLOR_LOC = 0x0B

.EQU PLAYER_X_LOC = 0x10
.EQU PLAYER_COLOR_LOC = 0x0F

.EQU SHIP_BULLETS_LOC = 0x20
.EQU PLAYER_BULLETS_LOC = 0x40
.EQU BULLETS_END_LOC = 0x4A

.EQU INTERRUPT_ID  = 0x20
.equ SSEG_CNTR_ID = 0x60
.equ SSEG_VAL_ID  = 0x80

; For loop iterators to artifically slow down the program

.EQU INSIDE_FOR_COUNT    =  0x2f
.EQU MIDDLE_FOR_COUNT    = 0x2f
.EQU OUTSIDE_FOR_COUNT   = 0x2f     
    
.EQU INSIDE_FOR_COUNT2    = 0x1f
.EQU MIDDLE_FOR_COUNT2    = 0x1f
.EQU OUTSIDE_FOR_COUNT2   = 0x1f


.CSEG
.ORG 0x10
 
;---------------------------------------------------------------------
;                           The Beginning
; 
;   The Beginning of the program
;---------------------------------------------------------------------

   SEI


        MOV R2, 0x81
        OUT R2, SSEG_CNTR_ID
        MOV R16, 0x00   
        MOV R31, 0x02
        MOV R30, SHIP_BULLET_RATE
        MOV  R10, END_ROW_SHIP
        MOV R11, 0x01   
        MOV R3, 0x03
        MOV R26, 0x00
        MOV R16, 0x00

;---------------------------------------------------------------------
;                           Clearing the screen
; 
;---------------------------------------------------------------------
        
reset:
        MOV R8, 0x27
        MOV R7, END_COL
        MOV R6, 0x00

reset_loop:
        MOV R4, R7
        MOV R5, R8
        call draw_dot
        SUB R8, 0x01
        BRNE reset_loop

        MOV R4, R7
        MOV R5, R8
        call draw_dot
        MOV R8, 0x27
        SUB R7, 0x01
        CMP R7, 0xFF
        BRNE reset_loop

        call reset_player
        call reset_ship
        call reset_bullets


;---------------------------------------------------------------------
;                   Drawing the ship and the player
; 
;---------------------------------------------------------------------
    
        call pause
        call draw_player
        call draw_ship
        call pause


;---------------------------------------------------------------------
;               The main code for the program
;---------------------------------------------------------------------


start:
        call draw_player_bullets

        CMP R10, 0x00
        BRNE move
        
        MOV R10, END_ROW_SHIP
        CALL down_ship

move:
        call move_ship
        call draw_ship_bullets
        SUB R10, 0x01

        CALL pause2
        brn start

;---------------------------------------------------------------------
;                               FUNCTIONS 
;---------------------------------------------------------------------


;---------------------------------------------------------------------
;                           Reset Player
;
;   Sets the player location to the middle of the bottom row
;   does not draw the player
;---------------------------------------------------------------------

reset_player:
            MOV R9, 0x14
            MOV R29, PLAYER_X_LOC
            MOV R3, 0x03

reset_player_loop:
            ST R9, (R29)
            ADD R9, 0x01
            ADD R29, 0x01
            SUB R3, 0x01
            BRNE reset_player_loop

            ret


;---------------------------------------------------------------------
;                           Draw Player
;---------------------------------------------------------------------

draw_player:
                MOV R25, PLAYER_X_LOC
                MOV R4,  END_COL
                MOV R6, PLAYER_COLOR
                MOV R3, 0x03

draw_player_loop:
                LD R5, (R25)
                call draw_dot

                ADD R25, 0x01
                SUB R3, 0x01
                BRNE draw_player_loop
                
                ret


;---------------------------------------------------------------------
;                           Move Player
;---------------------------------------------------------------------

move_player:
                call clear_player

                MOV R25, PLAYER_X_LOC
                MOV R4,  END_COL
                MOV R6, PLAYER_COLOR
                MOV R3, 0x03

                LD R9, (R25)
                CMP R12, 0x01
                BRNE test_left_player

test_right_player:
                CMP R9, END_ROW_PLAYER
                BRNE move_player_loop
                brn re_draw_player

test_left_player:
                CMP R9, 0x00
                BREQ re_draw_player
                
move_player_loop:
                LD R9, (R25)
                ADD R9, R12
                ST R9, (R25)
                MOV R5, R9
                call draw_dot

                ADD R25, 0x01
                SUB R3, 0x01
                BRNE move_player_loop
                brn end_move_player

re_draw_player: call draw_player

end_move_player:
                ret

;---------------------------------------------------------------------
;                           Clear Player
;---------------------------------------------------------------------

clear_player: 
                MOV R25, PLAYER_X_LOC
                MOV R4, END_COL
                MOV R6, 0x00

                MOV R3, 0x03

clear_player_loop:
                LD R5, (R25)
                call draw_dot

                ADD R25, 0x01
                SUB R3, 0x01
                BRNE clear_player_loop
                
                ret



;---------------------------------------------------------------------
;                           Down Ship
;
;   Moves the ship down one row and changes the ships direction
;---------------------------------------------------------------------

down_ship:      
                call clear_ship
                LD R9, SHIP_Y_LOC
                
                ADD R9, 0x01
                CMP R9, END_COL
                BREQ lose

                ST R9, SHIP_Y_LOC

                CMP R11, 0x01
                BREQ set_neg
        
                MOV R11, 0x01
                brn end_down_ship
                    
set_neg:        MOV R11, 0xFF
                
end_down_ship:
                call draw_ship
                ret
;---------------------------------------------------------------------
;                           Move Ship
;---------------------------------------------------------------------
move_ship:
                SUB R31, 0x01
                BRNE end_move_ship
            
                MOV R31, 0x02
 
                call clear_ship
                MOV R25, SHIP_X_LOC
                MOV R3, 0x03

move_ship_loop:
                LD R9, (R25)
                ADD R9, R11
                ST R9, (R25)
                ADD R25, 0x01
                SUB R3, 0x01
                BRNE move_ship_loop

                call draw_ship
end_move_ship:
                ret


;---------------------------------------------------------------------
;                           Draw Ship
;---------------------------------------------------------------------
draw_ship:
                MOV R24, SHIP_Y_LOC
                MOV R25, SHIP_X_LOC
                MOV R6, SHIP_COLOR
                MOV R3, 0x03

draw_ship_loop:
                LD R4, (R24)
                LD R5, (R25)
                call draw_dot

                ADD R25, 0x01
                SUB R3, 0x01
                BRNE draw_ship_loop
                
                ret

;---------------------------------------------------------------------
;                           Clear Ship
;---------------------------------------------------------------------

clear_ship: 
                MOV R24, SHIP_Y_LOC
                MOV R25, SHIP_X_LOC
                MOV R6, 0x00

                MOV R3, 0x03

clear_ship_loop:
                LD R4, (R24)
                LD R5, (R25)
                call draw_dot

                ADD R25, 0x01
                SUB R3, 0x01
                BRNE clear_ship_loop
                
                ret

;---------------------------------------------------------------------
;                           Reset Ship
;---------------------------------------------------------------------

reset_ship: 
                MOV R0, 0x00    
                MOV R24, SHIP_X_LOC
                ST R0, SHIP_Y_LOC
                MOV R3, 0x03

reset_ship_loop:
                ST R0, (R24)
                ADD R24, 0x01
                ADD R0, 0x01
                SUB R3, 0x01
                BRNE reset_ship_loop
                
                ret

;---------------------------------------------------------------------
;                           Reset Bullets
;---------------------------------------------------------------------

reset_bullets:  
                MOV R0, 0xFF
                MOV R24, SHIP_BULLETS_LOC

reset_bullets_loop:
                CMP R24, BULLETS_END_LOC
                BREQ end_reset_bullets
                
                ST R0, (R24)
                ADD R24, 0x01
                BRN reset_bullets_loop
                
end_reset_bullets:
                ret


;---------------------------------------------------------------------
;                           Move Bullet
;---------------------------------------------------------------------
move_bullet:    

hit_ship:       call collision_ship

hit_player:     

                call collision_player

                call clear_bullet
                LD R9, (R24)
                CMP R9, END_COL
                BREQ move_remove_bullet

                CMP R9, 0x00
                BREQ move_remove_bullet

                ADD R9, R21
                ST R9, (R24) 
                MOV R6, R13
                call draw_bullet
                brn end_move_bullet

move_remove_bullet:
                MOV R9, 0xFF
                ST R9, (R24)
                ST R9, (R25)
end_move_bullet:
                ret

;---------------------------------------------------------------------
;                           Collision Player
;---------------------------------------------------------------------
collision_player:
                MOV R7, PLAYER_X_LOC
                MOV R8, END_COL
                MOV R3, 0x03
                MOV R9, R8
                LD R22, (R24)
                CMP R9, R22
                BRNE end_collision_player
test_player:
                LD R9, (R7)
                LD R22, (R25)
                CMP R9, R22
                BREQ lose
                ADD R7, 0x01
                SUB R3, 0x01
                BRNE test_player

end_collision_player:
                ret
                
;---------------------------------------------------------------------
;                           Collision Ship
;---------------------------------------------------------------------
collision_Ship:
                MOV R7, SHIP_X_LOC
                MOV R8, SHIP_Y_LOC
                MOV R3, 0x03
                LD R9, (R8)
                LD R22, (R24)
                CMP R9, R22
                BRNE end_collision_ship
test_ship:
                LD R9, (R7)
                LD R22, (R25)
                CMP R9, R22
                BREQ win
                ADD R7, 0x01
                SUB R3, 0x01
                BRNE test_ship

end_collision_ship:
                ret
                




;---------------------------------------------------------------------
;                           Draw Bullet
;---------------------------------------------------------------------
draw_bullet:
                MOV R6, R13
                LD R4, (R24)
                LD R5, (R25)
                call draw_dot
                ret

;---------------------------------------------------------------------
;                           Clear Bullet
;---------------------------------------------------------------------

clear_bullet: 
                ;R0, 0xFF
                MOV R6, 0x00

                LD R4, (R24)
                LD R5, (R25)
                call draw_dot

                ;ST R0, (R24)
                ;ST R0, (R25)
                ret


;---------------------------------------------------------------------
;                           Draw Ship Bullets
;---------------------------------------------------------------------

draw_ship_bullets:
                MOV R25, SHIP_BULLETS_LOC
                MOV R13, SHIP_BULLET_COLOR
                MOV R24, R25
                ADD R24, 0x01
                MOV R21, 0x01
                MOV R15, 0x00

draw_ship_bullets_loop:
                call move_bullet

                ADD R25, 0x02
                ADD R24, 0x02
                ADD R15, 0x02
                CMP R15, 0x0A
                BRNE draw_ship_bullets_loop
                    
draw_ship_bullets_check:
                SUB R30, 0x01
                BRNE draw_ship_bullets_end

                MOV R30, SHIP_BULLET_RATE
                call start_ship_bullet
draw_ship_bullets_end:
                ret

;---------------------------------------------------------------------
;                           Draw Player Bullets
;---------------------------------------------------------------------

draw_player_bullets:
                MOV R25, PLAYER_BULLETS_LOC
                MOV R13, PLAYER_BULLET_COLOR
                MOV R24, R25
                ADD R24, 0x01
                MOV R21, 0xff
                MOV R15, 0x00

draw_player_bullets_loop:
                call move_bullet

                ADD R25, 0x02
                ADD R24, 0x02
                ADD R15, 0x02
                CMP R15, 0x0A
                BRNE draw_player_bullets_loop
                    
draw_player_bullets_end:
                ret



;---------------------------------------------------------------------
;                           Start Ship Bullet
;---------------------------------------------------------------------
start_ship_bullet:
                MOV R25, SHIP_BULLETS_LOC
                ADD R25, R26

                MOV R24, R25
                ADD R24, 0x01

                call clear_bullet

start_ship_bullet_main:
                MOV R9, SHIP_X_LOC
                ADD R9, 0x01
                LD R8, (R9)
                ST R8, (R25)

                LD R7, SHIP_Y_LOC
                ADD R7, 0x01
                ST R7, (R24)
                
                MOV R13, SHIP_BULLET_COLOR
                call draw_bullet

                ADD R26, 0x02
            
                CMP R26, 0x0A
                BRNE end_start_ship_bullet

                MOV R26, 0x00
end_start_ship_bullet:
                ret


;---------------------------------------------------------------------
;                       Start Player Bullet
;---------------------------------------------------------------------
start_player_bullet:
                MOV R25, PLAYER_BULLETS_LOC
                ADD R25, R16

                MOV R24, R25
                ADD R24, 0x01

                call clear_bullet

start_player_bullet_main:
                MOV R9, PLAYER_X_LOC
                ADD R9, 0x01
                LD R8, (R9)
                ST R8, (R25)

                MOV R7, END_COL
                SUB R7, 0x01
                ST R7, (R24)
                
                MOV R13, PLAYER_BULLET_COLOR
                call draw_bullet

                ADD R16, 0x02
            
animation:
                MOV  R4, END_COL
                MOV  R5, R8   

                mov R6, 0xE0
                call draw_dot
                call pause2
                mov R6, 0xFF
                call draw_dot

                CMP R16, 0x0A
                BRNE end_start_player_bullet

                MOV R16, 0x00
end_start_player_bullet:
                ret

;---------------------------------------------------------------------
;                           Draw Dot
;---------------------------------------------------------------------

draw_dot: 
        AND r5, 0x3F ; make sure top 2 bits cleared
        AND r4, 0x1F ; make sure top 3 bits cleared

dd_out: OUT r5, VGA_LADD ; write bot 8 address bits to register
        OUT r4, VGA_HADD ; write top 3 address bits to register
        OUT r6, VGA_COLOR ; write data to frame buffer
        RET
       

;---------------------------------------------------------------------
;                           Done
;
;   Don't do anything anymore
;---------------------------------------------------------------------

DONE:        BRN DONE


;---------------------------------------------------------------------
;                           Win
;
;   Turn the screen Green
;---------------------------------------------------------------------

win:    call pause
        MOV R8, 0x27
        MOV R7, END_COL
        MOV R6, 0x1C ;GREEN SCREEN
win_loop:
        MOV R4, R7
        MOV R5, R8
        call draw_dot
        SUB R8, 0x01
        BRNE win_loop

        MOV R4, R7
        MOV R5, R8
        call draw_dot
        SUB R7, 0x01
        CMP R7, 0xFF
        BRNE win_loop
    
        brn done


;---------------------------------------------------------------------
;                           Lose
;
;   Turn the screen red
;---------------------------------------------------------------------

lose:     
        call pause
        MOV R8, 0x27
        MOV R7, END_COL
        ADD R8, 0x01
        MOV R6, 0xE0 ;RED SCREEN

lose_loop:

        MOV R4, R7
        MOV R5, R8
        call draw_dot
        SUB R8, 0x01
        BRNE lose_loop

        MOV R4, R7
        MOV R5, R8
        call draw_dot
        SUB R7, 0x01
        CMP R7, 0xFF
        BRNE lose_loop
        brn done



;---------------------------------------------------------------------
;                           Pause
;
;   a long pause
;---------------------------------------------------------------------

pause:          MOV     R17, OUTSIDE_FOR_COUNT  
outside_for0:   SUB     R17, 0x01

                MOV     R18, MIDDLE_FOR_COUNT   
middle_for0:    SUB     R18, 0x01
             
                MOV     R19, INSIDE_FOR_COUNT   
inside_for0:    SUB     R19, 0x01
                BRNE    inside_for0
             
                OR      R18, 0x00              
                BRNE    middle_for0
             
                OR      R17, 0x00               
                BRNE    outside_for0
                ret

;---------------------------------------------------------------------
;                           Pause2
;
;   a shorter pause
;---------------------------------------------------------------------


pause2:         MOV     R17, OUTSIDE_FOR_COUNT2  
outside_for:    SUB     R17, 0x01

                MOV     R18, MIDDLE_FOR_COUNT2   
middle_for:     SUB     R18, 0x01
             
                MOV     R19, INSIDE_FOR_COUNT2   
inside_for:     SUB     R19, 0x01
                BRNE    inside_for
             
                or     R18, 0x00              
                BRNE    middle_for
             
                CMP      R17, 0x00               
                BRNE    outside_for
                ret

;---------------------------------------------------------------------
;                           INTERRUPTS
;---------------------------------------------------------------------


ISR: 

    IN R20, INTERRUPT_ID
    OUT  R20, SSEG_VAL_ID

    LSR R20
    BRCS moveRight

    LSR R20
    BRCS shoot   

    LSR R20  
    BREQ moveLeft

    brn ISR_END

shoot:  
      call start_player_bullet  
      brn ISR_END

moveLeft:
    MOV R12, 0xFF
    call move_player

    brn ISR_END

moveRight:
    MOV R12, 0x01
    
    call move_player

    brn ISR_END

ISR_END:
        RETIE


;---------------------------------------------------------------------
;                           INTERRUPT VECTOR
;---------------------------------------------------------------------

.CSEG
.ORG 0x3FF
VECTOR:      BRN ISR


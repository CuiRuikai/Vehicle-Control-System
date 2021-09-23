with Ada.Real_Time;              use Ada.Real_Time;
with Exceptions;                 use Exceptions;
with Vehicle_Interface;          use Vehicle_Interface;
with Vehicle_Message_Type;       use Vehicle_Message_Type;
with Swarm_Structures;           use Swarm_Structures;
with Swarm_Structures_Base;      use Swarm_Structures_Base;
with Vehicle_Control;            use Vehicle_Control;

package body Vehicle_Task_Type is

   task body Vehicle_Task is

      Vehicle_No        : Positive;
      Local_Message     : Inter_Vehicle_Messages;
      Charge_Threshold  : Vehicle_Charges          := Charge_Threshold_Generator;
      Start_Timestamp   : constant Time            := Clock;

   begin

      accept Identify (Set_Vehicle_No : Positive; Local_Task_Id : out Task_Id) do
         Vehicle_No     := Set_Vehicle_No;
         Local_Task_Id  := Current_Task;
      end Identify;

      select

         Flight_Termination.Stop;

      then abort

         Outer_task_loop : loop

            Wait_For_Next_Physics_Update;

            -- My Code
            -- Shrink Strategy
            Terminate_Check (Tickets    => Local_Message.Tickets,
                             Start_Time => Start_Timestamp,
                             No         => Vehicle_No);

            -- Message Receive
            Fetch_Message (Receiver => Local_Message, No => Vehicle_No);

            declare
               Globes_Around_A : constant Energy_Globes := Energy_Globes_Around; -- Detect Globes
            begin
               -- Send Globe Info
               if Globes_Around_A'Length /= 0 then
                  Local_Message.Globe_Posi := Choose_Globe (Vehicle_Position => Position,
                                                            Globes           => Globes_Around_A).Position;
                  Local_Message.Recorod_Time := Clock;
                  Send (Local_Message);
               elsif not Is_Expiry (Local_Message) then
                  Send (Local_Message);
               end if;
               -- Motion Coordination
               Steer_To_Globe_With_Check (Charge_Threshold, Position, Local_Message.Globe_Posi);
            end;

            delay 0.0; -- Check for uncontrolled vehicle
            if Throttle_Is_On_Idle then
               Steer_To_Globe_With_Check (Charge_Threshold, Position, Local_Message.Globe_Posi);
            end if;

         end loop Outer_task_loop;

      end select;

   exception
      when E : others => Show_Exception (E);

   end Vehicle_Task;

end Vehicle_Task_Type;

with Real_Type;                  use Real_Type;
with Vehicle_Interface;          use Vehicle_Interface;

package body Vehicle_Control is

   function Is_Expiry (Message : Inter_Vehicle_Messages) return Boolean is
     (To_Duration (Clock - Message.Recorod_Time) > Expiry_Duration);

   function Charge_Threshold_Generator return Vehicle_Charges is
      Charge_Threshold : Vehicle_Charges;
   begin
      loop
         Charge_Threshold := Vehicle_Charges (Real (Random (Gen)));
         exit when Charge_Threshold > Charge_Lower_Bound and then Charge_Threshold < Charge_Upper_Bound;
      end loop;
      return Charge_Threshold;
   end Charge_Threshold_Generator;

   function Safty_Point (Vehicle_Position, Globe_Position : Vector_3D) return Vector_3D is
     (Rotate (Current_Vector => Rotate (Current_Vector => Rotate (Current_Vector => Globe_Position + Safty_Distance * Norm (Vehicle_Position  - Globe_Position),
                                                                  Rotation_Axis  => Pitch_Axis,
                                                                  Rotation_Angle => Rotation_Angle),
                                        Rotation_Axis  => Roll_Axis,
                                        Rotation_Angle => Rotation_Angle),
              Rotation_Axis  => Yaw_Axis,
              Rotation_Angle => Rotation_Angle));

   ----------------------------------
   -- Optimize for Multiple Globes --
   ----------------------------------

   function Choose_Globe (Vehicle_Position : Vector_3D; Globes : Energy_Globes) return Energy_Globe is
      Nearest_Globe_Ix : Positive := Globes'First;
      Distance_Of_Nearest : Distances := abs (Vehicle_Position - Globes (Nearest_Globe_Ix).Position);
      Distance_Of_This : Distances;
   begin
      for Globe_Ix in Globes'Range loop
         Distance_Of_This := abs (Vehicle_Position - Globes (Globe_Ix).Position);
         if Distance_Of_This < Distance_Of_Nearest then
            Nearest_Globe_Ix := Globe_Ix;
            Distance_Of_Nearest := Distance_Of_This;
         end if;
      end loop;
      return Globes (Nearest_Globe_Ix);
   end Choose_Globe;

   ------------------------------
   -------- For Stage D ---------
   ------------------------------

   procedure Terminate_Check (Tickets : List; Start_Time : Time; No : Positive) is
      Ticket_Obtained : Boolean := False;
   begin
      if To_Duration (Clock - Start_Time) > Terminate_Stage_Start and then To_Duration (Clock - Start_Time) < Terminate_Stage_End then
         for Ix in Index'Range loop
            Ticket_Obtained := Tickets (Ix) = No;
            exit when Ticket_Obtained;
         end loop;
         if not Ticket_Obtained then
            Flight_Termination.Stop;
         end if;
      end if;
   end Terminate_Check;

   ------------------------------
   -------- Communication -------
   ------------------------------

   procedure Fetch_Message (Receiver : in out Inter_Vehicle_Messages; No : Positive) is
      Tmp_Message : Inter_Vehicle_Messages;
   begin
      loop -- Check New Messages
         exit when not Messages_Waiting;
         Receive (Tmp_Message);
         Update_Stored_Message (Old_Message => Receiver,
                                New_Message => Tmp_Message,
                                Vehicle_No => No);
      end loop;
   end Fetch_Message;

   procedure Update_Stored_Message (Old_Message : in out Inter_Vehicle_Messages; New_Message : Inter_Vehicle_Messages; Vehicle_No : Positive) is
      subtype Length is Natural;
      Length_Of_Old : Natural := Length'First;
      Length_Of_New : Natural := Length'First;
   begin
      -- Update for Globe_Posi
      if New_Message.Recorod_Time > Old_Message.Recorod_Time then
         Old_Message.Globe_Posi := New_Message.Globe_Posi;
         Old_Message.Recorod_Time := New_Message.Recorod_Time;
      end if;
      -- Update ticket info
      for Ix in Index'Range loop
         exit when Old_Message.Tickets (Ix) = Positive'Invalid_Value;
         Length_Of_Old := Natural'Succ (Length_Of_Old);
      end loop;
      for Ix in Index'Range loop
         exit when New_Message.Tickets (Ix) = Positive'Invalid_Value;
         Length_Of_New := Natural'Succ (Length_Of_New);
      end loop;

      if Length_Of_New >= Length_Of_Old then -- Ticket info update Principle
         Old_Message.Tickets := New_Message.Tickets;
         if Length_Of_New < List'Length then
            for Ix in Index'Range loop
               exit when Old_Message.Tickets (Ix) = Vehicle_No;
               if Old_Message.Tickets (Ix) = Positive'Invalid_Value then
                  Old_Message.Tickets (Ix) := Vehicle_No;
                  Old_Message.Timestamp := Clock;
                  exit;
               end if;
            end loop;
         end if;
      end if;
   end Update_Stored_Message;

   ------------------------------
   -------- Coordination --------
   ------------------------------

   procedure Steer_To_Globe_With_Check (Charge_Threshold : in out Vehicle_Charges; Vehicle_Position, Globe_Position : Vector_3D) is
   begin
      if Current_Charge <= Charge_Threshold then
         Set_Destination (Globe_Position);
         Set_Throttle (Full_Throttle);
         Charge_Threshold := Charge_Lower_Bound;
      else
         Set_Destination (Safty_Point (Vehicle_Position, Globe_Position));
         Set_Throttle (Cruise_Throttle);
      end if;
   end Steer_To_Globe_With_Check;

end Vehicle_Control;

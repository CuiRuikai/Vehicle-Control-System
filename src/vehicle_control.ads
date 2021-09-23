with Ada.Real_Time;              use Ada.Real_Time;
with Rotations;                  use Rotations;
with Vectors_3D;                 use Vectors_3D;
with Vehicle_Message_Type;       use Vehicle_Message_Type;
with Swarm_Structures;           use Swarm_Structures;
with Swarm_Structures_Base;      use Swarm_Structures_Base;
with Ada.Numerics.Float_Random;  use Ada.Numerics.Float_Random;

package Vehicle_Control is
   ------------------------------------------------------------------------------------
   ------------------------------------ Paramaters ------------------------------------
   ------------------- Not involved in inter vehicle communication --------------------
   -- General prinicple of adjustment:                                               --
   -- To support small swarm size => reduce Safty_Distance;                          --
   --                                increase Charge_Lower_Bound & Cruise_Throttle   --
   -- To support hugh swarm size  => reduce Charge_Lower_Bound & Cruise_Throttle;    --
   --                                set Safty_Distance = 0.4                        --
   -- Shrinking :                                                                    --
   --    Cannot correctly vanish  => Increase Terminate_Stage_Start by 20            --
   --    generally: 60s is enough                                                    --
   ------------------------------------------------------------------------------------
   Expiry_Duration         : constant Duration         := 1.0;
   Rotation_Angle          : constant Radiants         := 0.5;
   Safty_Distance          : constant Distances        := 0.25;
   Charge_Lower_Bound      : constant Vehicle_Charges  := 0.5;
   Charge_Upper_Bound      : constant Vehicle_Charges  := 1.0;
   Cruise_Throttle         : constant Throttle_T       := 0.8;
   Terminate_Stage_Start   : constant Duration         := 60.0;
   Terminate_Stage_End     : constant Duration         := 65.0; -- := Terminate_Stage_Start + 5.0
   -----
   Gen                     :          Generator;                -- Random Number Generator

   function Is_Expiry                    (Message : Inter_Vehicle_Messages)                     return Boolean;
   function Charge_Threshold_Generator                                                          return Vehicle_Charges;
   function Safty_Point                  (Vehicle_Position, Globe_Position : Vector_3D)         return Vector_3D;
   function Choose_Globe                 (Vehicle_Position : Vector_3D; Globes : Energy_Globes) return Energy_Globe;
   procedure Terminate_Check             (Tickets : List; Start_Time : Time; No : Positive);
   procedure Fetch_Message               (Receiver : in out Inter_Vehicle_Messages; No : Positive);
   procedure Update_Stored_Message       (Old_Message : in out Inter_Vehicle_Messages; New_Message : Inter_Vehicle_Messages; Vehicle_No : Positive);
   procedure Steer_To_Globe_With_Check   (Charge_Threshold : in out Vehicle_Charges; Vehicle_Position, Globe_Position : Vector_3D);

end Vehicle_Control;

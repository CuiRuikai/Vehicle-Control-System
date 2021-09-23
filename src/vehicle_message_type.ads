with Ada.Real_Time;         use Ada.Real_Time;
with Vectors_3D;            use Vectors_3D;
with Swarm_Size;            use Swarm_Size;

package Vehicle_Message_Type is

   type Index is range 1 .. Target_No_of_Elements;
   type List is array (Index) of Positive;

   type Inter_Vehicle_Messages is record
      Globe_Posi       : Vector_3D   := Zero_Vector_3D;
      Recorod_Time     : Time        := Clock;
      Tickets          : List        := (others => Positive'Invalid_Value);
      Timestamp        : Time        := Clock;
   end record;

end Vehicle_Message_Type;

with Ada.Text_IO;
with Generic_ECS;

procedure Demonstration is
   type Component_Kind_Type is (Position_Kind);
   package ECS is new Generic_ECS (Component_Kind_Type);

   type Position_Type is new ECS.Component_Interface_Type with record
      X, Y, Z : Float;
   end record;
   type Position_Access_Type is access all Position_Type;

   procedure System
     (Registry : ECS.Registry_Type;
      Entity   : ECS.Entity_Type)
   is
      Position : constant Position_Access_Type := Position_Access_Type (Registry.Get (Entity, Position_Kind));
   begin
      Ada.Text_IO.Put_Line ("X:" & Position.X'Img);
   end System;

   Registry : ECS.Registry_Type := ECS.Initialize;
begin
   -- Create 5 entities
   for Index in 1 .. 5 loop
      declare
         Entity   : constant ECS.Entity_Type      := Registry.Create;
         Position : constant Position_Access_Type := new Position_Type;
      begin
         Position.X := Float (Index);

         -- Set the component only for odd indexes
         if Index mod 2 = 1 then
            Registry.Set (Entity, Position_Kind, ECS.Component_Interface_Class_Access_Type (Position));
         end if;
      end;
   end loop;

   -- Print x for each entities implementing the Position component
   declare
      Selection : ECS.Selection.Selection_Type;
   begin
      Selection.Select_Component (Position_Kind);
      Selection.Selection_Kind (ECS.Selection.Inclusive);

      Registry.Each (Selection, System'Access);
   end;
end Demonstration;

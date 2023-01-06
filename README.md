# Generic_ECS

Generic_ECS is an entity-component system made for Ada. It is inspired by the very good [Entt]([Entt](https://github.com/skypjack/entt)) (I didn't benchmark Generic_ECS, but I'm certainly far from Entt performances and functionnalities).

## Demonstration
```ada
with Ada.Text_IO;
with Generic_ECS;

procedure Demonstration is
   type Component_Kind_Type is (Position_Kind);
   package ECS is new Generic_ECS (Component_Kind_Type);

   type Position_Type is new ECS.Component_Interface_Type with record
      X, Y, Z : Float;
   end record;
   type Position_Access_Type is access all Position_Type;

   procedure System (Registry : ECS.Registry_Type; Entity : ECS.Entity_Type) is
      Position : constant Position_Access_Type := Position_Access_Type (Registry.Get (Entity, Position_Kind));
   begin
      Ada.Text_IO.Put_Line ("X:" & Position.X'Img);
   end System;

   Registry : ECS.Registry_Type := ECS.Initialize;
begin
   -- Create 5 entities
   for Index in 1 .. 5 loop
      declare
         Entity   : constant ECS.Entity_Type := Registry.Create;
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
```

## Usage

As its name suggest, Generic_ECS is a generic package that takes an enumeration of your components :

```ada
type Component_Kind_Type is new (Transform_Kind, Render_Kind);

package ECS is new Generic_ECS (Component_Kind_Type);
```

This gives you access to three subpackages:
- Component: which is an interface to implement your components
- Selection: a package to handle component selection. A component selection is just an array associating a boolean to each component. You can also specify a selection kind like an exclusive or inclusive selection.
- Registry: the main package. A registry is the manager for your entities, components and systems. It's the only way you can interact with them.

The important elements of each subpackage (types or subprograms) has been renamed in Generic_ECS for easy access.

First of all you have to create a registry:
```ada
Registry : ECS.Registry_Type := ECS.Initialize;
```

From it, you can create an entity which simply an unique identifier:
```ada
Entity : ECS.Entity_Type := Registry.Create;
```
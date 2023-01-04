with Internal.Generic_Component;

generic
   with package Component_Package is new Internal.Generic_Component (<>);
package Internal.Generic_Selection with
  Preelaborate, Pure
is

   type Selection_Kind_Type is
     (Inclusive,           -- At least one of the component
      Exclusive);          -- Exactly all the selected components

   type Selection_Type is tagged private;

   -- Return an object with no components selected
   function Select_None
     (Selection_Kind : Selection_Kind_Type := Inclusive)
      return Selection_Type;

   -- Return an object with every components selected
   function Select_All
     (Selection_Kind : Selection_Kind_Type := Inclusive)
      return Selection_Type;

   -- Return the kind of the selection
   function Selection_Kind
     (Selection : Selection_Type)
      return Selection_Kind_Type;

   -- Set the kind of the selection
   procedure Selection_Kind
     (Selection : out Selection_Type;
      Kind      :     Selection_Kind_Type);

   -- Select a component
   procedure Select_Component
     (Selection : out Selection_Type;
      Component :     Component_Package.Component_Kind_Type);

   -- Unselect a component
   procedure Unselect_Component
     (Selection : out Selection_Type;
      Component :     Component_Package.Component_Kind_Type);

   -- Return whether the component is selected or not
   function Is_Selected
     (Selection : Selection_Type;
      Component : Component_Package.Component_Kind_Type)
      return Boolean;

   function "+"
     (Component : Component_Package.Component_Kind_Type)
      return Selection_Type;

   function "+"
     (LHS, RHS : Component_Package.Component_Kind_Type)
      return Selection_Type;

   function "+"
     (Selection : Selection_Type;
      Component : Component_Package.Component_Kind_Type)
      return Selection_Type;

   function "="
     (Selection        : Selection_Type;
      Components_Array : Component_Package.Component_Boolean_Array_Type)
      return Boolean;

private

   type Selection_Type is tagged record
      Kind       : Selection_Kind_Type;
      Components : Component_Package.Component_Boolean_Array_Type;
   end record;

end Internal.Generic_Selection;

with Internal.Generic_Component;
with Internal.Generic_Registry;
with Internal.Generic_Selection;

generic
   type Component_Kind_Type is (<>);
package Generic_ECS is

   package Component is new Internal.Generic_Component (Component_Kind_Type => Component_Kind_Type);
   package Selection is new Internal.Generic_Selection (Component_Package => Component);
   package Registry is new Internal.Generic_Registry (Selection_Package => Selection);

   -- Useful renames
   subtype Component_Interface_Type is Component.Component_Interface_Type;
   subtype Component_Interface_Class_Access_Type is Component.Component_Interface_Class_Access_Type;
   subtype Component_Boolean_Array_Type is Component.Component_Boolean_Array_Type;

   subtype Registry_Type is Registry.Registry_Type;
   subtype Entity_Type is Registry.Entity_Type;
   subtype System_Type is Registry.System_Type;
   subtype System_Interface_Type is Registry.System_Interface_Type;

   function Initialize return Registry_Type renames Registry.Initialize;

end Generic_ECS;

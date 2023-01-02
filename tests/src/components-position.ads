with ECS;

package Components.Position is

   type Position_Component_Type is new ECS.Component.Component_Interface_Type with record
      X, Y, Z : Float;
   end record;

   type Position_Component_Access_Type is access all Position_Component_Type;

end Components.Position;
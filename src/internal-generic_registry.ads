with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Internal.Generic_Selection;

generic
   with package Selection_Package is new Internal.Generic_Selection (<>);
package Internal.Generic_Registry with
  Preelaborate
is

   package Component_Package renames Selection_Package.Component_Package;

   --------------------------
   -- Registry management --
   --------------------------

   type Registry_Type is tagged private;
   type Registry_Access_Type is access all Registry_Type;

   -- Initialize and return a new registery
   function Initialize return Registry_Type;

   -- Remove all the entities from the registery
   procedure Clear (Registry : in out Registry_Type);

   -- Return the number of entities in use
   function Count
     (Registry : Registry_Type)
      return Natural;

   -----------------------
   -- Entity management --
   -----------------------
   type Entity_Type is private;

   -- Create an entity in the register
   -- Return the created entity
   function Create
     (Registry : in out Registry_Type)
      return Entity_Type;

   -- Destroy the entity
   -- Do nothing if the entity was already destroyed or doesn't exist
   procedure Destroy
     (Registry : in out Registry_Type;
      Entity   :        Entity_Type);

   -- Return whether or not the registery has the entity
   function Has
     (Registry : Registry_Type;
      Entity   : Entity_Type)
      return Boolean;

   --------------------------
   -- Component management --
   --------------------------

   -- Assign the component to the entity in the registery
   procedure Set
     (Registry  : in out Registry_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type);

   -- Assign the component to the entity in the registery
   -- Return an access to the component
   function Set
     (Registry  : in out Registry_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type)
      return Component_Package.Component_Interface_Class_Access_Type;

   -- Remove the component designated by kind from the entity
   procedure Unset
     (Registry  : in out Registry_Type;
      Entity    :        Entity_Type;
      Component :        Component_Package.Component_Kind_Type);

   -- Remove the components from the entity
   -- If selection is set to exclusive, it unsets the components only if the entity
   -- has all the selected components
   procedure Unset
     (Registry   : in out Registry_Type;
      Entity     :        Entity_Type;
      Components :        Selection_Package.Selection_Type);

   -- Unset the selected components from all entities
   -- If selection is set to exclusive, it unsets the components for the entities
   -- that have all the selected components
   procedure Unset
     (Registry   : in out Registry_Type;
      Components :        Selection_Package.Selection_Type);

   -- Return an array with each component set to true if it is set for the entity
   function Get_Set_Components
     (Registry : Registry_Type;
      Entity   : Entity_Type)
      return Component_Package.Component_Boolean_Array_Type;

   -- Check if the entity has component kind
   function Has
     (Registry  : Registry_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Boolean;

   -- Check if the entity has the specified selection
   function Has
     (Registry   : Registry_Type;
      Entity     : Entity_Type;
      Components : Selection_Package.Selection_Type)
      return Boolean;

   -- Return an access to the component specified by kind from the entity
   function Get
     (Registry  : Registry_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Component_Package.Component_Interface_Class_Access_Type;

      -----------------------
      -- System management --
      -----------------------

   type System_Type is access procedure
       (Registry : Registry_Type;
        Entity   : Entity_Type);

   -- Run the system on each entity according to the component selection
   procedure Each
     (Registry   : in out Registry_Type;
      Components :        Selection_Package.Selection_Type;
      System     :        System_Type);

   -- Run the system on each entity
   procedure Each
     (Registry : in out Registry_Type;
      System   :        System_Type);

   -- Interface allows more possibilities than a simple subprogram
   type System_Interface_Type is interface;

   -- This procedure will be called on each entity
   procedure Run
     (System   : in out System_Interface_Type;
      Registry :        Registry_Access_Type;
      Entity   :        Entity_Type) is abstract;

      -- Run the system on each entity according to the component selection
   procedure Each
     (Registry   : in out Registry_Type;
      Components :        Selection_Package.Selection_Type;
      System     : in out System_Interface_Type'Class);

   -- Run the system on each entity
   procedure Each
     (Registry : in out Registry_Type;
      System   : in out System_Interface_Type'Class);

private

   -- An entity is just an unique id
   type Entity_Type is new Positive;

   -- Return a hash from the entity
   function Hash_Entity
     (Entity : Entity_Type)
      return Ada.Containers.Hash_Type;

   -- Associate each component kind to an access to Component_Interface'Class
   type Component_Access_Array_Type is
     array (Component_Package.Component_Kind_Type) of Component_Package.Component_Interface_Class_Access_Type;

   package Entity_Component_Hashed_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => Entity_Type,
      Element_Type    => Component_Access_Array_Type,
      Hash            => Hash_Entity,
      Equivalent_Keys => "=",
      "="             => "=");

   type Registry_Type is tagged record
      Last_Entity : Entity_Type;
      Entities    : Entity_Component_Hashed_Maps.Map;
   end record;

end Internal.Generic_Registry;

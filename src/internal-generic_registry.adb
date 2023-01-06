package body Internal.Generic_Registry is

   --------------------------
   -- Registry management --
   --------------------------

   function Initialize return Registry_Type is
   begin
      return Registry : Registry_Type do
         Registry.Last_Entity := Entity_Type'First;
         Registry.Entities    := Entity_Component_Hashed_Maps.Empty_Map;
      end return;
   end Initialize;

   procedure Clear (Registry : in out Registry_Type) is
   begin
      Registry.Entities.Clear;
   end Clear;

   function Count
     (Registry : Registry_Type)
      return Natural
   is
   begin
      return Natural (Registry.Entities.Length);
   end Count;

   -----------------------
   -- Entity management --
   -----------------------

   function Create
     (Registry : in out Registry_Type)
      return Entity_Type
   is
      Entity : constant Entity_Type := Registry.Last_Entity;
   begin
      Registry.Entities.Include (Entity, (others => null));
      Registry.Last_Entity := Entity_Type'Succ (Registry.Last_Entity);

      return Entity;
   end Create;

   procedure Destroy
     (Registry : in out Registry_Type;
      Entity   :        Entity_Type)
   is
   begin
      Registry.Entities.Delete (Entity);
   end Destroy;

   function Has
     (Registry : Registry_Type;
      Entity   : Entity_Type)
      return Boolean
   is
   begin
      return Registry.Entities.Contains (Entity);
   end Has;

   --------------------------
   -- Component management --
   --------------------------

   procedure Set
     (Registry  : in out Registry_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type)
   is
   begin
      if not Registry.Has (Entity) then
         return;
      end if;

      Registry.Entities (Entity) (Kind) := Component;
   end Set;

   function Set
     (Registry  : in out Registry_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type)
      return Component_Package.Component_Interface_Class_Access_Type
   is
   begin
      Registry.Set
        (Entity    => Entity,
         Kind      => Kind,
         Component => Component);

      return Registry.Get
          (Entity    => Entity,
           Component => Kind);
   end Set;

   procedure Unset
     (Registry  : in out Registry_Type;
      Entity    :        Entity_Type;
      Component :        Component_Package.Component_Kind_Type)
   is
   begin
      if not Registry.Has (Entity) then
         return;
      end if;

      Registry.Entities (Entity) (Component) := null;
   end Unset;

   procedure Unset
     (Registry   : in out Registry_Type;
      Entity     :        Entity_Type;
      Components :        Selection_Package.Selection_Type)
   is
      procedure Unset_Components is
      begin
         for Kind in Component_Package.Component_Kind_Type loop
            if Components.Is_Selected (Kind) then
               Registry.Entities (Entity) (Kind) := null;
            end if;
         end loop;
      end Unset_Components;
   begin
      if not Registry.Has (Entity) then
         return;
      end if;

      case Components.Selection_Kind is
         when Selection_Package.Inclusive =>
            Unset_Components;
         when Selection_Package.Exclusive =>
            if Registry.Has (Entity, Components) then
               Unset_Components;
            end if;
      end case;
   end Unset;

   procedure Unset
     (Registry   : in out Registry_Type;
      Components :        Selection_Package.Selection_Type)
   is
   begin
      for Entity_Cursor in Registry.Entities.Iterate loop
         Registry.Unset (Entity_Component_Hashed_Maps.Key (Entity_Cursor), Components);
      end loop;
   end Unset;

   function Has
     (Registry  : Registry_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Boolean
   is
      use type Component_Package.Component_Interface_Class_Access_Type;
   begin
      if not Registry.Has (Entity) then
         return False;
      end if;

      return Registry.Entities (Entity) (Component) /= null;
   end Has;

   function Has
     (Registry   : Registry_Type;
      Entity     : Entity_Type;
      Components : Selection_Package.Selection_Type)
      return Boolean
   is
      use type Selection_Package.Selection_Type;

      Entity_Components : Component_Package.Component_Boolean_Array_Type;
   begin
      if not Registry.Has (Entity) then
         return False;
      end if;

      Entity_Components := Registry.Get_Set_Components (Entity);

      return Components = Entity_Components;
   end Has;

   function Get
     (Registry  : Registry_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Component_Package.Component_Interface_Class_Access_Type
   is
   begin
      if not Registry.Has (Entity) then
         return null;
      end if;

      return Registry.Entities (Entity) (Component);
   end Get;

   function Get_Set_Components
     (Registry : Registry_Type;
      Entity   : Entity_Type)
      return Component_Package.Component_Boolean_Array_Type
   is
      Components : Component_Package.Component_Boolean_Array_Type := (others => False);
   begin
      if not Registry.Has (Entity) then
         return Components;
      end if;

      for Component_Kind in Component_Package.Component_Kind_Type loop
         Components (Component_Kind) := Registry.Has (Entity, Component_Kind);
      end loop;

      return Components;
   end Get_Set_Components;

   ------------
   -- System --
   ------------
   procedure Each
     (Registry   : in out Registry_Type;
      Components :        Selection_Package.Selection_Type;
      System     :        System_Type)
   is
      Entity : Entity_Type;
   begin
      for Cursor in Registry.Entities.Iterate loop
         Entity := Entity_Component_Hashed_Maps.Key (Cursor);
         if Registry.Has (Entity, Components) then
            System (Registry, Entity);
         end if;
      end loop;
   end Each;

   procedure Each
     (Registry : in out Registry_Type;
      System   :        System_Type)
   is
   begin
      for Cursor in Registry.Entities.Iterate loop
         System (Registry, Entity_Component_Hashed_Maps.Key (Cursor));
      end loop;
   end Each;

   procedure Each
     (Registry   : in out Registry_Type;
      Components :        Selection_Package.Selection_Type;
      System     : in out System_Interface_Type'Class)
   is
      Entity : Entity_Type;
   begin
      for Cursor in Registry.Entities.Iterate loop
         Entity := Entity_Component_Hashed_Maps.Key (Cursor);
         if Registry.Has (Entity, Components) then
            System.Run (Registry'Unchecked_Access, Entity);
         end if;
      end loop;
   end Each;

   procedure Each
     (Registry : in out Registry_Type;
      System   : in out System_Interface_Type'Class)
   is
   begin
      for Cursor in Registry.Entities.Iterate loop
         System.Run (Registry'Unchecked_Access, Entity_Component_Hashed_Maps.Key (Cursor));
      end loop;
   end Each;

   -------------
   -- Private --
   -------------

   function Hash_Entity
     (Entity : Entity_Type)
      return Ada.Containers.Hash_Type
   is
   begin
      return Ada.Containers.Hash_Type (Entity);
   end Hash_Entity;

end Internal.Generic_Registry;

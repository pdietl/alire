with Semantic_Versioning.Extended;

private with Ada.Containers.Indefinite_Ordered_Maps;

package Alire.Solutions.Diffs is

   type Changes is
     (Added,      -- A new release
      Removed,    -- A removed dependency of any kind
      External,   -- A new external dependency
      Upgraded,   -- An upgraded release
      Downgraded, -- A downgraded release
      Pinned,     -- A release being pinned
      Unpinned,   -- A release being unpinned
      Unchanged,  -- An unchanged dependency/release
      Unsolved    -- A missing dependency
     );

   type Diff is tagged private;
   --  Encapsulates the differences between two solutions

   function Between (Former, Latter : Solution) return Diff;
   --  Create a Diff from two solutions

   function Change (This : Diff; Crate : Crate_Name) return Changes;
   --  Summary of what happened with a crate

   function Contains_Changes (This : Diff) return Boolean;
   --  Says if there are, in fact, changes between both solutions

   function Latter_Is_Complete (This : Diff) return Boolean;
   --  Says if the new solution is complete

   procedure Print (This         : Diff;
                    Changed_Only : Boolean;
                    Prefix       : String       := "   ";
                    Level        : Trace.Levels := Trace.Info);
   --  Print a summary of changes between two solutions. Prefix is prepended to
   --  every line.

private

   type Install_Status is (Unsolved, Unneeded, Hinted, Linked, Needed);
   --  Unsolved will apply to all crates when a solution is invalid. TODO: when
   --  reasons for solving failure are tracked, improve the diff output.

   type Crate_Status (Status : Install_Status := Unneeded) is record
      case Status is
         when Needed =>
            Pinned   : Boolean;
            Version  : Semantic_Versioning.Version;
         when Linked =>
            Path     : UString;
         when Hinted | Unsolved =>
            Versions : Semantic_Versioning.Extended.Version_Set;
         when Unneeded =>
            null;
      end case;
   end record;

   function Best_Version (Status : Crate_Status) return String;
   --  Used to provide the most precise version available depending on the
   --  crate status.

   type Crate_Changes is record
      Former, Latter : Crate_Status := (Status => Unneeded);
   end record;

   package Change_Maps is new Ada.Containers.Indefinite_Ordered_Maps
     (Crate_Name, Crate_Changes);

   type Diff is tagged record
      Former_Complete,
      Latter_Complete : Boolean := False;
      --  Empty solutions but with different validity still count as changes.

      Changes        : Change_Maps.Map;
   end record;

end Alire.Solutions.Diffs;

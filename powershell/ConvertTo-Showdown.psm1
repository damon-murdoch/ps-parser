Function ConvertTo-StatString
{
  Param(
    # The stats hash table which will be parsed
    [Alias()][Parameter(Mandatory=$True)][Object]$Stats, 

    # Switch, if set will process as IVs rather than EVs
    [Alias()][Parameter(Mandatory=$False)][Switch]$IVs = $False
  );

  # Pretty text for each key
  $Text = @{
    'hp' = 'HP'
    'atk' = 'Atk'
    'def' = 'Def'
    'spa' = 'SpA'
    'spd' = 'SpD'
    'spe' = 'Spe'
  };

  # Order stats should be written in
  $Order = @(
    'hp',
    'atk',
    'def',
    'spa',
    'spd',
    'spe'
  );

  # List of stats
  # Will be joined on '/'
  $List = [System.Collections.ArrayList]@();

  # Loop over the list enumerator
  ForEach($Name in $Order)
  {
    # Get the value from the stats
    $Value = $Stats[$Name];

    # If ivs is set, ensure the value is not 31 (default) OR 
    # If ivs is not set, ensure it is not 0 (default)
    If (-Not (($IVs -And ($Value -Eq 31)) -Or ((-Not $IVs) -And ($Value -Eq 0))))
    {
      # Add the key and the pretty text to the list
      $List += ([String]$Value) + ' ' + $Text[$Name];
    }
  }

  # Return the list joined on slashes
  Return ($List -Join " / ");
}


Function Get-SortedSets
{
  Param(
    # Json Object to convert to a sorted team
    [Alias()][Parameter(Mandatory=$True)][Object]$InputObject
  );

  # List of restricted pokemon
  # If a pokemon name matches any of these, 
  # it will be prioritised
  $RESTRICTEDLIST = @(
    "Mewtwo*", 
    "Ho-oh",
    "Lugia",
    "*Groudon*",
    "*Kyogre*",
    "*Rayquaza*",
    "Dialga", 
    "Palkia", 
    "Giratina", 
    "Kyurem*",
    "Xerneas",
    "Yveltal",
    "Solgaleo", 
    "Lunala",
    "*Necrozma*",
    "*Zacian*",
    "*Zamazenta*",
    "Eternatus",
    "*Calyrex*"
  );

  # Restricted Pokemon list
  $Restricteds = [System.Collections.ArrayList]@();

  # Mega Pokemon List
  $Megas = [System.Collections.ArrayList]@();

  # Z Pokemon List
  $ZHolder = [System.Collections.ArrayList]@();

  # Gmax Pokemon List
  $Gmax = [System.Collections.ArrayList]@();

  # Other pokemon
  $Other = [System.Collections.ArrayList]@();

  # Loop over all of the pokemon
  ForEach($Set in $InputObject)
  {
    # If set is added yet or not
    $Added = $False;

    # Loop over all of the restricteds
    ForEach($Restricted in $RESTRICTEDLIST)
    {
      # If the species matches the pokemon name
      If ($Set.Species -Like $Restricted)
      {
        # Add it to the restricted list
        $Restricteds += $Set;

        # Set has beem added
        $Added = $True;

        # Break this loop
        Break;
      }
    }

    # Set is not added
    If (-Not $Added)
    {
      # Check if item is mega stone (Ensuring it is not eviolite instead)
      If (-Not ($Set.item -Like "Eviolite") -And ($Set.item -Like "*ite*"))
      {
        $Megas += $Set;
      }
      # Check if item is z crystal
      ElseIf ($Set.item -Like "* Z")
      {
        $ZHolder += $Set;
      }
      # If pokemon is gmax
      ElseIf ($Set.Species -Like "*-Gmax")
      {
        $Gmax += $Set;
      }
      Else # Nothing special
      {
        $Other += $Set;
      }
    }
  }

  # Create a combined array list of all of the sorted arrays
  $Combined = [System.Collections.ArrayList]@();

  # If there is more than one restricted in the team, sort the array and add it to the combined list
  If ($Restricteds.Count -Gt 0) { $Combined += ($Restricteds | Sort-Object -Property Species); }

  # If there is more than one mega in the team, sort the array and add it to the combined list
  If ($Megas.Count -Gt 0) { $Combined += ($Megas | Sort-Object -Property Species); }

  # If there is more than one z holder in the team, sort the array and add it to the combined list
  If ($ZHolder.Count -Gt 0) { $Combined += ($ZHolder | Sort-Object -Property Species); }

  # If there is more than one gmax in the team, sort the array and add it to the combined list
  If ($Gmax.Count -Gt 0) { $Combined += ($Gmax | Sort-Object -Property Species); }

  # If there is more than other pokemon in the team, sort the array and add it to the combined list
  If ($Other.Count -Gt 0) {  $Combined += ($Other | Sort-Object -Property Species); }

  # Return the combined array
  Return $Combined;
}

Function ConvertTo-ShowdownLibrary
{
  Param(
    # Json Object to convert to a showdown string
    [Alias()][Parameter(Mandatory=$True)][Object]$InputObject, 

    # Switch, if set will format the string uniformly
    [Alias()][Parameter(Mandatory=$False)][Switch]$Clean = $False,

    # Switch, if set will sort the sets alphabetically
    [Alias()][Parameter(Mandatory=$False)][Switch]$Sort = $False
  );

  # List of teams to return
  $Content = [System.Collections.ArrayList]@();

  # Loop over the enumerated formats
  ForEach($Format in ($InputObject.GetEnumerator() | Sort-Object -Property Name))
  {
    # Loop over the enumerated folders
    ForEach($Folder in ($Format.Value.GetEnumerator() | Sort-Object -Property Name))
    {
      # List of teams for the folder
      $Teams = [System.Collections.ArrayList]@();

      # If we are sorting the teams
      ForEach($Team in $Folder.Value)
      {
        # If we are sorting the teams
        If ($Sort)
        {
          # Sort the team object using custom sort function
          $Team.Sets = Get-SortedSets -InputObject $Team.Sets;

          # Return $Team.Sets;
        }

        # Add the team to the teams list
        $Teams += $Team;
      }

      # If we are sorting the teams
      If ($Sort)
      {
        # Sort teams using name of first pokemon
        $Teams = $Teams | Sort-Object -Property "Sets.Species";
      }
      Else # Teams are unsorted
      {
        # Sort the names alphabetically using the name
        $Teams = $Teams | Sort-Object -Property Name;
      }

      # Loop over the teams in the folder
      ForEach($Team in $Folder.Value)
      {
        # If the folder is set to defalt
        If ($Folder.Name -Eq 'default')
        {
          # Do not include in title string
          $Content += "=== [$($Format.Name)] $($Team.Name) ===";
        }
        Else # Folder is not default
        {
          # Include folder in title string
          $Content += "=== [$($Format.Name)] $($Folder.Name) / $($Team.Name) ===";
        }

        # Add blank line to content
        $Content += "";

        # Add the team to the content
        $Content += ConvertTo-ShowdownString -InputObject $Team.Sets;
        
        # Add blank line to content
        $Content += "";
      }
    }
  }

  # Return text content to calling process
  Return $Content;
}

Function ConvertTo-ShowdownString 
{
  Param(
    # Json Object to convert to a showdown string
    [Alias()][Parameter(Mandatory=$True)][Object]$InputObject, 

    # Switch, if set will sort the sets alphabetically
    [Alias()][Parameter(Mandatory=$False)][Switch]$Sort = $False
  );

  # List of sets to return
  $List = [System.Collections.ArrayList]@();

  # If the sort switch is specified
  If ($Sort)
  {
    # Sort the input object based on the species (alphabetical)
    $InputObject = $InputObject | Sort-Object -Property Species;
  }

  # Loop over the sets
  Foreach($Set in $InputObject)
  {
    # Lines for the item
    $Item = [System.Collections.ArrayList]@();

    # Nickname (Species) @ Item
    $RowName = '';

    # If the set has a nickname
    If ($Set.nickname)
    {
      # Add the nickname and species to the export
      $RowName = $Set.nickname + ' (' + $Set.species + ')';
    }
    Else # Nickname not set
    {
      # Add just the species to the export
      $RowName = $Set.species;
    }

    # If an item is set
    If ($Set.item)
    {
      # Add the item to the line
      $RowName += ' @ ' + $Set.item;
    }

    # Add the name row to the items list
    $Item += $RowName;

    # Ability: Ability
    
    # If an ability is set
    If ($Set.ability)
    {
      # Add the ability row to the items list
      $Item += "Ability: " + $Set.ability;
    }

    # Get the stat string  for ivs, ivs switch true
    $IVStr = ConvertTo-StatString -Stats $Set.ivs -IVs;

    # IVs string not empty
    If ($IVStr)
    {
      # Add to item list
      $Item += "IVs: " + $IVStr;
    }

    # Get the stat string for evs, ivs switch false
    $EVStr = ConvertTo-StatString -Stats $Set.evs;

    # EVs string not empty
    If ($EVStr)
    {
      # Add to item list
      $Item += "EVs: " + $EVStr;
    }

    # Loop over the misc. attributes
    ForEach($Other in $Set.other.GetEnumerator() | Sort-Object -Property Name)
    {
      # Convert the first letter of the key to upper case
      $Upper = $Other.Name.Substring(0, 1).ToUpper() + $Other.Name.Substring(1, ($Other.Name.Length - 1));

      # Add the key, value to the set
      $Item += $Upper + ": " + $Other.Value;
    }

    # If nature is specified
    If ($Set.nature)
    {
      # Add the nature to the form
      $Item += $Set.nature + ' nature';
    }

    # Loop over the moves
    ForEach($Move in $Set.moves)
    {
      # Add the move line to the form
      $Item += '- ' + $Move;
    }

    # Add the item to the list, joined on newlines
    $List += $Item -Join "`n";
  }

  # Return the list, joined on double new lines
  Return $List -Join "`n`n";
}
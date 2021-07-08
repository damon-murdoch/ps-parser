# Nickname (Species) (Gender) @ Item
# Key: Value
# EVs: x HP / x Atk / x Def / x SpA / x SpD / x Spe
# IVs: x HP / x Atk / x Def / x SpA / x SpD / x Spe
# Nature Nature
# - Move 1
# - Move 2
# - Move 3
# - Move 4

# statTemplate(init: int): object
# Return a pokemon stat field template, 
# with a default value in each field of 0
# or 'init' if specified
function Get-StatTemplate
{
  Param(
    # Default value of the stats object, 0 if unspecified
    [Alias()][Parameter(Mandatory=$False)][Int]$Default = 0
  );

  return @{
    'hp'=$Default;
    'atk'=$Default;
    'def'=$Default;
    'spa'=$Default;
    'spd'=$Default;
    'spe'=$Default;
  };
}

# setTemplate(void): object
# Return a pokemon set template
function Get-SetTemplate
{
  return @{
    'species'='';
    'nickname'='';
    'gender'='';
    'ability'='';
    'evs'=(Get-StatTemplate -Default 0);
    'ivs'=(Get-StatTemplate -Default 31);
    'nature'='';
    'item'='';
    'moves'=@();
    'other'=@{}
  };
}

# parseStats(stats: object, str: string): object
# Given an existing stats object and a string containing stats, 
# Parses the string and returns a new stats object containing the fields
function ConvertFrom-StatString
{
  Param(
    # [Hashtable] Stats table which will be updated
    [Alias()][Parameter(Mandatory=$True)][Hashtable]$Stats, 

    # [String] String which will have values pulled from
    [Alias()][Parameter(Mandatory=$True)][String]$String 
  );

  # Split on the seperator
  $Sep = $String.Split('/');

  # Loop over the stats
  Foreach($Stat in $Sep)
  {
    # Split the stat on the space
    $Split = $Stat.Trim().Split(' ');

    # Switch on the stat
    Switch($Split[1].toLower())
    {
      'hp' { 
        $Stats['hp'] = ([Int]$Split[0])
      }      
      'atk' { 
        $Stats['atk'] = ([Int]$Split[0])
      }
      'def' { 
        $Stats['def'] = ([Int]$Split[0])
      }
      'spa' { 
        $Stats['spa'] = ([Int]$Split[0])
      }
      'spd' { 
        $Stats['spd'] = ([Int]$Split[0])
      }
      'spe' { 
        $Stats['spe'] = ([Int]$Split[0])
      }
    }
  }

  # Return the updated object
  Return $Stats;
}

# parseSet(str: string): object
# Given a string sequence containing
# Pokemon showdown sets, returns a json
# list  of the sets converted to objects.
Function ConvertFrom-ShowdownString
{
  Param(
    # Input string which will be converted to a hash table
    [Alias()][Parameter(Mandatory=$True)]$InputString
  );

  # Empty array of sets
  $Sets = @();

  # Current set null by default
  $Current = $Null;

  # Loop over each line in the string
  Foreach($Line in $InputString.Split("`n"))
  {

    # Series of increasingly obscure cases 
    # Check if this is the first line of the pokemon
    # Can be formatted a bunch of different ways
    # Case 1: No Item, Gender, Nickname: Species
    # Case 2: No Item, Gender: Nickname (Species)
    # Case 3: No Item: Nickname (Species) (Gender)
    # Case 4: Full: Nickname (Species) (Gender) @ Item

    If ($Line.Contains('@') -Or # Will always trigger if item is specified
        $Line.Contains('(') -Or ( # Will always trigger if gender / nn is specified
          $Line.Trim() -Ne '' -And # Blocks if string is empty
          $Line.Trim().Split(' ').Length -Eq 1) # Handles when ONLY species is specified
      )
    {
      # If a set template has not been created yet, create one
      # If one already exists, add it to the list and create a new one
      If ($Null -Ne $Current)
      {
        # Add the current set to the list
        $Sets += $Current;
      }

      # Create a new set object
      $Current = Get-SetTemplate;

      # If the set is male
      If ($Line.ToLower().Contains('(m)'))
      {
        # Remove gender from the line
        $Line = $Line.Replace('(m)','').Replace('(M)','');

        # Set gender to male
        $Current.gender = 'm';
      }

      # If the set is female
      If ($Line.ToLower().Contains('(f)'))
      {
        # Remove gender from the line
        $Line = $Line.Replace('(f)','').Replace('(F)','');

        # Set gender to female
        $Current.gender = 'f';
      }

      # If the line still contains any '(', must be a nickname
      If ($Line.Contains("("))
      {
        # Split the string on any '(' or ')'
        $Li = ($Line.Trim() -Split {@('(',')') -Contains $_});

        # Add the nickname to the object
        $Current.nickname = $Li[0].Trim();

        # Remove the first and second elements from the string
        $A,$Li = $Li;

        # Add the species to the object
        $Current.species = $Li[0].Trim();

        # Remove the first and second elements from the string
        $A,$Li = $Li;

        # Return the cleaned up line
        $Line = $Li.Trim();
      }

      # If the line contains a '@', must be an item after it
      If ($Line.Contains('@'))
      {
        # Split the string on the '@' token
        $Li = $Line.Trim().Split('@');

        # If the first index is not null
        If ($Li[0].Trim() -Ne '')
        {
          # Set the species to the value of the first index
          $Current.species = $Li[0].Trim();
        }

        # If the second index is not null
        If ($Li[1].Trim() -Ne '')
        {
          # Set the item to the value of the second index
          $Current.item = $Li[1].Trim();
        }
      }
    }
    
    # If the line contains the 'ability:' text
    ElseIf ($Line.ToLower().Contains('ability:'))
    {
      # Set the ability to the ability pulled from the text
      $Current.ability = $Line.Split(':')[1].Trim();
    }
    
    # If the line contains the 'evs:' text
    ElseIf ($Line.ToLower().Contains('evs:'))
    {
      # Parse the evs string from the line
      $Li = $Line.Split(':')[1].Trim();

      # Get the evs object from the evs string
      $Current.evs = ConvertFrom-StatString -Stats $Current.evs -String $Li;
    }

    # If the line contains the 'ivs:' text
    ElseIf ($Line.ToLower().Contains('ivs:'))
    {
      # Parse the evs string from the line
      $Li = $Line.Split(':')[1].Trim();

      # Get the evs object from the evs string
      $Current.ivs = ConvertFrom-StatString -Stats $Current.ivs -String $Li;
    }

    # All other random arbitrary k/v pairs, add to the other property
    ElseIf ($Line.Contains(':'))
    {
      # Key: Value, i.e. Shiny: Yes, Ability: Intimidate, etc.

      # Split the line on the ':'
      $Li = $Line.Trim().Split(':');

      # Assign a 'key' in the 'other' property of the current object to the 'value'
      $Current.other[$Li[0].Trim().ToLower()] = $Li[1].Trim();
    }

    # If the line contains the 'nature' text
    ElseIf ($Line.ToLower().Contains('nature'))
    {
      # Retrieve the nature from the string and add it to the object
      $Current.nature = $Line.Split(' ')[0].Trim();
    }

    # If the line starts with a '-', is a move
    ElseIf ($Line.Trim().StartsWith('-'))
    {
      # Add the move text to the moves list for the set
      $Current.moves += $Line.Replace('-','').Trim();
    }
  }

  # Made it to the end, add the last set to the stack
  $Sets += $Current;

  # Return all of the parsed sets
  Return $Sets;
}
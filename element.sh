#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


if [[ -z $1 ]] 
then
  #if no argument is passed
  echo Please provide an element as an argument.
else
  #if an argument is passed it checks the database

  #check if argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
      #atomic_number was provided
      ATOMIC_NUMBER=$1
  else
      #search by symbol or name
      SEARCH=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
      if [[ -z $SEARCH ]]
      then
        # Search by name
        SEARCH=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
        if [[ -z $SEARCH ]]
        then
          #element was not found in database
          ATOMIC_NUMBER="Error 404"
        else
          #element was found by its name
          ATOMIC_NUMBER=$SEARCH
        fi
      else
        # Element found by its symbol
        ATOMIC_NUMBER=$SEARCH
      fi
  fi

  if [[ $ATOMIC_NUMBER = 'Error 404' ]]
  then
    echo "I could not find that element in the database."
  else
    #search all necessary information to display
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    TYPE=$($PSQL "SELECT type FROM properties JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
    MELT_P=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
    BOIL_P=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")

    #final display of information
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT_P celsius and a boiling point of $BOIL_P celsius."
  fi
fi
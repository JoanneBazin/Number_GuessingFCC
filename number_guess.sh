#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

RANDOM_NUMBER=$(( RANDOM % 1000 ))


echo Enter your username:
read NAME

USERNAME=$($PSQL "SELECT username FROM users WHERE username='$NAME'")

if [[ -z $USERNAME ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")
  USERNAME=$($PSQL "SELECT username FROM users WHERE username='$NAME'")
  
  echo Welcome, $USERNAME! It looks like this is your first time here.

else
  USER_INFOS=$($PSQL "SELECT * FROM users WHERE username='$NAME'")

  echo $USER_INFOS | while read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done

fi

echo Guess the secret number between 1 and 1000:
NUMBER_OF_GUESSES=0

while [[ $OUTPUT_NUMBER != $RANDOM_NUMBER ]]
do
  
  read OUTPUT_NUMBER

  if [[ ! $OUTPUT_NUMBER =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else

    if [[ $OUTPUT_NUMBER > $RANDOM_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES ++))
      echo "It's lower than that, guess again:"

    elif [[ $OUTPUT_NUMBER < $RANDOM_NUMBER ]]
    then
      (( NUMBER_OF_GUESSES ++))
      echo "It's higher than that, guess again:"

    else
      (( NUMBER_OF_GUESSES ++))
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  
    fi
  fi
done

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$NAME'")
(( GAMES_PLAYED ++ ))
INSERT_NEW_GAME=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$NAME'")

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
if [ -z $BEST_GAME ] || [ $BEST_GAME > $NUMBER_OF_GUESSES ]
then
  INSERT_NEW_SCORE=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$NAME'")
fi

#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"
# add attempt and update db
ATTEMPTS=1
# add users
LOGIN() {
  echo "Enter your username:"
  read NAME
  # get user name from db
  USER=$($PSQL "SELECT * FROM users INNER JOIN attempts USING(user_id);")
  # if not found
  if [[ -z $USER ]]
  then
    INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$NAME');")
    echo Welcome, $USER! It looks like this is your first time here.
  else
    WELCOME_BACK
  fi
  echo $USER | while IFS="|" read USER_ID NAME GAME_ID ATTEMPT USER_ID2
  do
    # insert attempt into db
    INSERT_ATTEMPT=$($PSQL "INSERT INTO attempts(attempt, user_id) VALUES($ATTEMPTS, $USER_ID);")
    PLAY_GAME
  done
}

PLAY_GAME() {
  NUMBER=$(( RANDOM%1000 + 1 ))
  echo Guess the secret number between 1 and 1000;
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
    PLAY_GAME
  fi
}

PLAY_GAME
until [[ $GUESS == $NUMBER ]]; do
  GET_GUESS again
  # update attempt until done
  # if guess is high
  if [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  ((ATTEMPTS = ATTEMPTS + 1))
  UPDATE_ATTEMPT=$($PSQL "UPDATE attempts SET attempt=$ATTEMPTS WHERE game_id=$GAME_ID AND user_id=$USER_ID;")
done

WELCOME_BACK() {
  GAME_DATA=$($PSQL "SELECT MIN(attempt), COUNT(games_id) FROM attempts WHERE user_id=$USER_ID;")
  echo $GAME_DATA | while IFS="|" read BEST_GAME READ_GAMES_PLAYED
  do
    echo Welcome back, $NAME! You have played $READ_GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done
}
echo You guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!

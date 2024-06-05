#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

 
  SERVICES=$($PSQL "SELECT service_id, name from services;")
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done  

  read SERVICE_ID_SELECTED
  MIN_SERVICE=$($PSQL "SELECT MIN(service_id) from services;")
  MAX_SERVICE=$($PSQL "SELECT MAX(service_id) from services;")
  if [[ $SERVICE_ID_SELECTED -gt $MAX_SERVICE ]] || [[ $SERVICE_ID_SELECTED -lt $MIN_SERVICE ]]
  then
  MAIN_MENU "I could not find that service. What would you like today?"
  else
  echo -e "\nWhat's your phone number?"
  # get customer info
  read CUSTOMER_PHONE
  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if not found  
  if [[ -z $CUSTOMER_NAME ]]
    # insert to customers
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get time of appointment
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name from services where service_id=$SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your$SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone='$CUSTOMER_PHONE'")
  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED);")
  # get appointment info
  echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
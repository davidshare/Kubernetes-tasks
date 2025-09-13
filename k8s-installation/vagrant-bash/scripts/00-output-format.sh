#!/bin/bash

set -e  # Exit on error

task_echo () {
  local message="$1"
  local line_length=40  # Customizable length of the line
  local equal_signs=""
  local spaces=""

  # Calculate number of '=' signs and spaces needed
  local line_side_length=$(( (line_length - ${#message}) / 2 ))

  # Create the left and right side of the '=' signs
  for (( i=0; i<line_side_length; i++ )) do
    equal_signs+="="
  done

  # Calculate the remaining space
  local remaining_space=$((line_length - (2*line_side_length) - ${#message}))

  # Add the spaces
  for (( i=0; i<remaining_space; i++ )) do
    spaces+=" "
  done

  echo "${equal_signs}${spaces}${message}${spaces}${equal_signs}"
}
#!/usr/bin/env bash

# Copyright (c) 2015, Kofinas Miltiadis
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Authors:
#   Kofinas Miltiadis <mkofinas@gmail.com>

# This function creates elegant borders around the elements of a matrix.
# To see a demo of its use, run the "box_draw_test" script in the
# corresponding "../../test" folder.

current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $current_directory"/box_draw_symbols"

box_draw() {
  local num_rows=$1
  local num_cols=$2
  local matrix_elements_size=$((num_rows*num_cols))

  shift
  shift

  declare -a matrix_elements=( $(for (( i = 0; i < $matrix_elements_size; i++ )); do echo 0; done) )
  declare -a matrix_elements_colors=( $(for (( i = 0; i < $matrix_elements_size;
  i++ )); do echo -e "\e[0m"; done) )

  local i=0
  local j=0
  local k=0
  # Split the arguments array into 2 matrices.
  for var in "$@"; do
    if [[ $i -ge $matrix_elements_size ]]; then
      matrix_elements_colors[$j]=$var
      j=$((j+1))
    else
      matrix_elements[$k]=$var
      k=$((k+1))
    fi
    i=$((i+1))
  done

  # echo "${matrix_elements[@]}"
  # echo "${matrix_elements_colors[@]}"

  ## Find the maximum length of each column.
  declare -a max_col_lengths=( $(for (( i = 0; i < $num_cols; i++ )); do echo 0; done) )

  local col_index
  local element
  local element_length
  for linear_index in ${!matrix_elements[@]}; do
    col_index=$((linear_index%num_cols))
    element=${matrix_elements[$linear_index]}
    element_length=${#element}
    if (( element_length > max_col_lengths[$col_index] )); then
      max_col_lengths[$col_index]=$element_length
    fi
  done

  ## Find the indices of the middle columns.
  declare -a middle_col_indices=( $(for (( i = 0; i < $num_cols-1; i++ )); do echo 0; done) )

  local adder
  for (( i = 0; i < num_cols-1; i++ )); do
    for (( j = 0; j <= i; j++ )); do
      if [[ $j = 0 ]]; then
        adder=2
      else
        adder=3
      fi
      ((middle_col_indices[$i]+=$((max_col_lengths[j]+adder))))
    done
  done

  ## Find the width the final window.
  local sum_max_lengths
  sum_max_lengths=0
  for length in ${max_col_lengths[@]}; do
    sum_max_lengths=$((sum_max_lengths+length))
  done
  sum_max_lengths=$((sum_max_lengths+4+(num_cols-1)*3))

  ## Final matrix declaration.
  declare -a final_matrix=( $(for (( i = 0; i < $num_rows+2; i++ )); do echo 0; done) )

  ## First and Last line
  local first_line
  local last_line
  local middle_col_flag
  first_line=$arc_down_and_right
  last_line=$arc_up_and_right
  for (( i = 0; i < sum_max_lengths-2; i++ )); do
    middle_col_flag=0
    for middle_column in ${middle_col_indices[@]}; do
      if [[ $i = $middle_column ]]; then
        middle_col_flag=1
      fi
    done

    if [[ $middle_col_flag = 1 ]]; then
      first_line+=$down_and_horizontal_line
      last_line+=$up_and_horizontal_line
    else
      first_line+=$horizontal_line
      last_line+=$horizontal_line
    fi
  done
  first_line+=$arc_down_and_left
  last_line+=$arc_up_and_left
  final_matrix[0]=$first_line
  final_matrix[${num_rows}+1]=$last_line

  ## Text Lines
  local space_str
  local linear_index
  local color_element
  local padded_spaces
  local line_to_print
  space_str=" "
  for (( i = 0; i < num_rows; i++ )); do
    line_to_print="$vertical_line""$space_str"
    for (( j = 0; j < num_cols; j++ )); do
      linear_index=$((i*num_cols+j))
      element=${matrix_elements[$linear_index]}
      color_element=${matrix_elements_colors[$linear_index]}
      element_length=${#element}
      padded_spaces=$((max_col_lengths[j]-element_length+1))
      line_to_print+="$color_element$element$COLOR_OFF"
      for (( k = 0; k < padded_spaces; k++ )); do
        line_to_print+="$space_str"
      done
      if (( j < num_cols - 1 )); then
        line_to_print+="$vertical_line"
        line_to_print+="$space_str"
      fi
    done
    line_to_print+="$vertical_line"
    final_matrix[$i+1]="$line_to_print"
  done

  ## Print the resulting matrix.
  for (( i = 0; i < $num_rows+2; i++ )); do
    echo -e "${final_matrix[$i]}"
  done

}


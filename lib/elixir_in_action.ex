# Exercises:
# A list_len/1 function that calculates the length of a list
# A range/2 function that takes two integers, from and to, and returns a list of all integer numbers in the given range
# A positive/1 function that takes a list and returns another list that contains only the positive numbers from the input list

# Streams
# Using large_lines!/1 as a model, write the following functions:
# A lines_lengths!/1 that takes a file path and returns a list of numbers, with each number representing the length of the corresponding line from the file.
# A longest_line_length!/1 that returns the length of the longest line in a file.
# A longest_line!/1 that returns the contents of the longest line in a file.
# A words_per_line!/1 that returns a list of numbers, with each number representing the word count in a file. Hint: To find the word count of a line, use length(String.split(line)).

defmodule ElixirInAction do
  # Recursion
  def list_len(list), do: list_len(0, list)
  defp list_len(acc, []), do: acc
  defp list_len(acc, [_h | t]), do: list_len(acc + 1, t)

  def range(from, to) when is_integer(to), do: range(from, [to])
  def range(from, acc = [h | _t]) when h > from, do: range(from, [h - 1 | acc])
  def range(_from, acc), do: acc

  def positive(list), do: positive(list, [])
  defp positive([h | t], acc) when h <= 0, do: positive(t, acc)
  defp positive([h | t], acc) when h > 0, do: positive(t, [h | acc])
  defp positive([], acc), do: acc
  # Recursion
  # Streams

  # Streams
end

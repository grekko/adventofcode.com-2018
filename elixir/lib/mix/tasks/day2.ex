# --- Day 2: Inventory Management System ---
# You stop falling through time, catch your breath, and check the screen on the
# device. "Destination reached. Current Year: 1518. Current Location: North
# Pole Utility Closet 83N10." You made it! Now, to find those anomalies.
#
# Outside the utility closet, you hear footsteps and a voice. "...I'm not sure
# either. But now that so many people have chimneys, maybe he could sneak in
# that way?" Another voice responds, "Actually, we've been working on a new
# kind of suit that would let him fit through tight spaces like that. But, I
# heard that a few days ago, they lost the prototype fabric, the design plans,
# everything! Nobody on the team can even seem to remember important details of
# the project!"
#
# "Wouldn't they have had enough fabric to fill several boxes in the warehouse?
# They'd be stored together, so the box IDs should be similar. Too bad it would
# take forever to search the warehouse for two similar box IDs..." They walk
# too far away to hear any more.
#
# Late at night, you sneak to the warehouse - who knows what kinds of paradoxes
# you could cause if you were discovered - and use your fancy wrist device to
# quickly scan every box and produce a list of the likely candidates (your
# puzzle input).
#
# To make sure you didn't miss any, you scan the likely candidate boxes again,
# counting the number that have an ID containing exactly two of any letter and
# then separately counting those with exactly three of any letter. You can
# multiply those two counts together to get a rudimentary checksum and compare
# it to what your device predicts.
#
# For example, if you see the following box IDs:
#
# - abcdef contains no letters that appear exactly two or three times.
# - bababc contains two a and three b, so it counts for both.
# - abbcde contains two b, but no letter appears exactly three times.
# - abcccd contains three c, but no letter appears exactly two times.
# - aabcdd contains two a and two d, but it only counts once.
# - abcdee contains two e.
# - ababab contains three a and three b, but it only counts once.
#
# Of these box IDs, four of them contain a letter which appears exactly twice,
# and three of them contain a letter which appears exactly three times.
# Multiplying these together produces a checksum of 4 * 3 = 12.
#
# What is the checksum for your list of box IDs?
#
#
# --- Part Two ---
#
# Confident that your list of box IDs is complete, you're ready to find the
# boxes full of prototype fabric.
#
# The boxes will have IDs which differ by exactly one character at the same
# position in both strings. For example, given the following box IDs:
#
# abcde
# fghij <- take this
# klmno
# pqrst
# fguij <- compare
# axcye
# wvxyz
#
# The IDs abcde and axcye are close, but they differ by two characters (the
# second and fourth). However, the IDs fghij and fguij differ by exactly one
# character, the third (h and u). Those must be the correct boxes.
#
# What letters are common between the two correct box IDs? (In the example
# above, this is found by removing the differing character from either ID,
# producing fgij.)

defmodule Mix.Tasks.Day2 do
  use Mix.Task

  def run(_args) do
    { :ok, input } = File.read("../inputs/day2.txt")
    box_ids = input |> String.split
    checksum = checksum_for_box_ids(box_ids)
    IO.puts("Try #{checksum} for the checksum!")

    common_box_id = detect_common_letter_box_ids(box_ids)
    IO.puts("If I am not mistaken `#{common_box_id}` should open the door!")
  end

  def detect_common_letter_box_ids([ box_id | box_ids ]) do
    if partner = find_partner(box_id, box_ids) do
      partner
    else
      detect_common_letter_box_ids(box_ids)
    end
  end


  @doc ~S"""
  Finds partner for given box_id in list of box_ids.

  ## Examples

      iex> Mix.Tasks.Day2.find_partner("abcd", ["abxx", "abxy", "abdd"])
      "abd"

  """

  def find_partner(box_id, box_ids) do
    partner = box_ids |> Enum.find(fn(x) -> char_difference_one(box_id, x) end)
    if partner do
      chars1 = partner |> String.codepoints
      chars2 = box_id |> String.codepoints

      chars1
        |> Enum.zip(chars2)
        |> Enum.filter(fn {c1, c2} -> c1 == c2 end)
        |> Enum.map(fn {c, c} -> c end)
        |> Enum.join
    end
  end

  def char_difference_one(word1, word2) do
    chars1 = word1 |> String.codepoints
    chars2 = word2 |> String.codepoints

    chars1
      |> Enum.zip(chars2)
      |> Enum.count(fn {c1, c2} -> c1 != c2 end)
      |> Kernel.==(1)
  end

  @doc ~S"""
  Calculates checksum for the given box ids.

  ## Examples

      iex> Mix.Tasks.Day2.checksum_for_box_ids(["aaabcd", "aabbbc"])
      2

      iex> Mix.Tasks.Day2.checksum_for_box_ids(["abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"])
      12
  """

  def checksum_for_box_ids(box_ids) do
    duos = box_ids
           |> Enum.map(fn(x) -> count_word_has_n_letters(x, 2) end)
           |> Enum.sum
    triplets = box_ids
               |> Enum.map(fn(x) -> count_word_has_n_letters(x, 3) end)
               |> Enum.sum
    duos * triplets
  end

  def count_word_has_n_letters(word, count) do
    if word_has_exactly_n_letters(word, count), do: 1, else: 0
  end

  def word_has_exactly_n_letters(word, count) do
    chars = word |> String.codepoints
    chars |> Enum.any?(fn(x) -> Enum.count(chars, fn(char) -> char == x end) == count end)
  end
end

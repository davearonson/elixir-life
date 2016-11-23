defmodule Life do

  # TODO: figure out a not-too-klugey way to make rows and cols adjustable

  @cols 60
  def cols, do: @cols
  @rows 20
  def rows, do: @rows

  @neighbor_vectors for x <- -1..1, y <- -1..1, x != 0 or y != 0, do: [x, y]

  @esc ""
  @ansi_home  "#{@esc}[H"
  @ansi_clr_to_eol "#{@esc}[K"
  @ansi_clr_to_eos "#{@esc}[J"

  def new(cells \\ []) do
  MapSet.new(cells |> Enum.map(&put_in_range/1))
  end

  def add_cell(cells, row, col) do
    cells |> MapSet.put(put_in_range([row, col]))
  end

  def put_in_range([row, col]) do
    [rem(row + @rows, @rows), rem(col + @cols, @cols)]
  end

  def run(cells, count \\ 0, prev \\ nil, before \\ nil, gen \\ 1)
  def run(cells, 1,     _,     _,     gen), do: show(cells, gen)
  def run(cells, _,     cells, _,     _  ), do: IO.puts "\nReached static stability"
  def run(cells, _,     _,     cells, _  ), do: IO.puts "\nReached dynamic stability"
  def run(cells, count, prev,  _,     gen)  do
    show(cells, gen)
    run(Life.next_generation(cells), count - 1, cells, prev, gen + 1)
  end

  def show(cells, gen) do
    IO.write "#{@ansi_home}"
    if gen == 1, do: IO.write "#{@ansi_clr_to_eos}"
    IO.write to_s(cells)
    IO.puts @ansi_clr_to_eol
    IO.write "Generation #{gen} (#{MapSet.size(cells)} cells)"
  end

  def next_generation(cells) do
    cond do
      MapSet.size(cells) == 0 -> cells
      true                    -> MapSet.union(survivors(cells),
                                              births(cells))
    end
  end

  def next_state(true , num_neighbors), do: Enum.member?([2,3], num_neighbors)
  def next_state(false, num_neighbors), do: num_neighbors == 3

  def survivors(cells) do
    cells |> Enum.filter(&(should_survive?(&1, cells))) |> MapSet.new
  end

  def should_survive?(loc, cells) do
    next_state(true, count_neighbors(loc, cells))
  end

  def count_neighbors(loc, cells) do
    get_neighbors(loc) |> Enum.filter(&(alive?(&1, cells))) |> Enum.count
  end

  def get_neighbors(loc) do
    @neighbor_vectors |> Enum.map(&(add_locs(loc, &1)))
  end

  def add_locs([row, col], [delta_row, delta_col]) do
    [rem(row + delta_row + @rows, @rows), rem(col + delta_col + @cols, @cols)]
  end

  def alive?(loc, cells, want \\ true) do
    if MapSet.member?(cells, loc) == want, do: loc, else: nil
  end

  def births(cells) do
    cells
    |> Enum.map(&get_neighbors/1)
    |> Enum.filter(&(alive?(&1, cells, false)))
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.union/2)
    |> Enum.filter(&(should_come_alive?(&1, cells)))
    |> MapSet.new
  end

  def should_come_alive?(loc, cells) do
    next_state(false, count_neighbors(loc, cells))
  end

  def to_s(cells) do
    0..(@rows - 1)
    |> Enum.map(&(to_s_row(&1, cells)))
    |> Enum.join("#{@ansi_clr_to_eol}\n")
  end

  def to_s_row(row, cells) do
    0..(@cols - 1)
    |> Enum.map(&(char_for(row, &1, cells)))
    |> Enum.join
    |> String.trim_trailing
  end

  def char_for(row, col, cells) do
    if alive?([row, col], cells), do: "@", else: " "
  end

  def randomize(num_cells \\ div(@rows * @cols, 10), acc \\ MapSet.new)
  def randomize(0        , acc), do: acc
  def randomize(num_cells, acc) do
    randomize(num_cells - 1,
              MapSet.put(acc, [:rand.uniform(@rows) - 1,
                               :rand.uniform(@cols) - 1]))
  end

end

Code.load_file("life.exs")

ExUnit.start
ExUnit.configure exclude: :pending, trace: true

defmodule AnagramTest do
  use ExUnit.Case

  describe "#next_generation" do
    test "2x2 is stable" do
      world = Life.new([[0,0],[0,1], [1,0],[1,1]])
      assert Life.next_generation(world) == world
    end
    test "hexagon is stable" do
      world = Life.new([[0,1],[0,2],
                        [1,0],[1,3],
                        [2,1],[2,2]])
      assert Life.next_generation(world) == world
    end
    test "horizontal traffic light goes to vertical" do
      world = Life.new([[1,0],[1,1],[1,2]])
      assert Life.next_generation(world) == 
        Life.new([[0,1],[1,1],[2,1]])
    end
    test "vertical traffic light goes to horizontal" do
      world = Life.new([[0,1],[1,1],[2,1]])
      assert Life.next_generation(world) == 
        Life.new([[1,0],[1,1],[1,2]])
    end
  end

  describe "#new" do
    test "is empty by default" do
      assert Life.new |> MapSet.size == 0
    end
    test "accepts a list" do
      cells = [[0,0],[1,1]]
      assert Life.new(cells) |> MapSet.size == (cells |> Enum.count)
    end
    test "puts stuff in range" do
      assert Life.new([[-1,-1]]) ==
        MapSet.new([[Life.rows - 1, Life.cols - 1]])
    end
  end

  describe "#add_cell" do
    test "adds to empty" do
      assert Life.new |> Life.add_cell(1,1) |> MapSet.size == 1
    end
    test "adds to non-empty" do
      assert Life.new
             |> Life.add_cell(1,1)
             |> Life.add_cell(2,2)
             |> MapSet.size
             == 2
    end
    test "doesn't duplicate" do
      assert Life.new
             |> Life.add_cell(1,1)
             |> Life.add_cell(1,1)
             |> MapSet.size
             == 1
    end
    test "puts stuff in range" do
      assert Life.new |> Life.add_cell(-1,-1) ==
        MapSet.new([[Life.rows - 1, Life.cols - 1]])
    end
  end

  describe "#count_neighbors" do
    test "solo has zero" do
      assert Life.count_neighbors([1,1], Life.new([[1,1]])) == 0
    end
    test "full grid has 8" do
      world = Life.new([[0,0],[0,1],[0,2],
                        [1,0],[1,1],[1,2],
                        [2,0],[2,1],[2,2]])
      assert Life.count_neighbors([1,1], world) == 8
    end
    test "wraps" do
      world = Life.new([[0,0],[0,1],[1,0],[0,-1],[-1,0]])
      assert Life.count_neighbors([0,0], world) == 4
    end
  end

  describe "live cells" do
    test "die with one neighbor"       , do: refute Life.next_state(true, 1)
    test "survive with two neighbors"  , do: assert Life.next_state(true, 2)
    test "survive with three neighbors", do: assert Life.next_state(true, 3)
    test "die with four neighbors"     , do: refute Life.next_state(true, 4)
  end

  describe "dead cells" do
    test "stay dead with two neighbors" , do: refute Life.next_state(false, 2)
    test "get born with three neighbors", do: assert Life.next_state(false, 3)
    test "stay dead with four neighbors", do: refute Life.next_state(false, 4)
  end


end

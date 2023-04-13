# frozen_string_literal: true

# Help is building metrics from group by queries
class ArrayMatrix
  attr_accessor :data, :row_ids, :col_ids, :n_cols, :n_rows

  def initialize(counts, row_keys, col_keys)
    return unless row_keys && counts

    @row_ids = row_keys
    @col_ids = col_keys

    @n_rows = row_ids.size
    @n_cols = @col_ids.nil? ? 1 : @col_ids.size

    # @data = [[0] * n_cols] * n_rows

    build_data(counts)
  end

  def prepend_row(ary, r_id = nil)
    data.insert(0, ary)
    row_ids.insert(0, r_id)
    @n_rows += 1
  end

  def prepend_column(ary, c_id = nil)
    insert_column(ary, 0, c_id)
  end

  def append_column(ary, c_id = nil)
    insert_column(ary, -1, c_id)
  end

  def insert_column(ary, index, c_id)
    dt = data.transpose
    dt.insert(index, ary)
    @data = dt.transpose
    col_ids.insert(index, c_id)
    @n_cols += 1
  end

  def rows_sum
    data.transpose.map(&:sum)
  end

  def row(i)
    data[i]
  end

  def rows
    data
  end

  def rows_with_ids
    row_ids.each_with_index do |r_id, r|
      yield(data[r], r_id)
    end
  end

  def columns_sum
    data.map(&:sum)
  end

  def column(i)
    columns[i]
  end

  def columns
    data.transpose
  end

  def columns_with_ids
    col_ids.each_with_index do |c_id, c|
      yield(columns[c], c_id)
    end
  end

  def create_links!(link_method)
    row_ids.each_with_index do |r_id, r|
      col_ids.each_with_index do |c_id, c|
        data[r][c] = link_method.call(data[r][c], r_id, c_id)
      end
    end
  end

  private

  def build_data(counts)
    @data = []
    (0..n_rows - 1).each do |r|
      row = []
      r_id = row_ids[r]
      (0..n_cols - 1).each do |c|
        c_id = col_ids[c]
        row[c] = counts[[r_id, c_id]].to_i
      end
      @data << row
    end
  end
end

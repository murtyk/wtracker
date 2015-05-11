require 'rails_helper'

describe ArrayMatrix do
  before :each do
    @counts = {
      [1, 1] => 1,
      [2, 2] => 2,
      [3, 3] => 3,
      [3, 4] => 100
    }

    @row_keys = [1, 2, 3]
    @col_keys = [1, 2, 3, 4]
  end
  it 'performs as expected' do
    am = ArrayMatrix.new(@counts, @row_keys, @col_keys)

    expect(am.rows.count).to eq(3)
    expect(am.columns.count).to eq(4)

    expect(am.rows[0]).to eq([1, 0, 0, 0])
    expect(am.columns[3]).to eq([0, 0, 100])

    rows_sum = am.rows_sum
    expect(rows_sum).to eq([1, 2, 3, 100])

    columns_sum = am.columns_sum
    expect(rows_sum).to eq([1, 2, 3, 100])

    am.prepend_column(columns_sum)
    am.prepend_row(am.rows_sum)

    expect(am.row(0)[0]).to eq(106)

    id_data = []
    am.rows_with_ids do |r, id|
      id_data << [id, r]
    end
    expect(id_data[0]).to eq [nil, [106, 1, 2, 3, 100]]
    expect(id_data[-1]).to eq [3, [103, 0, 0, 3, 100]]

    id_data = []
    am.columns_with_ids do |c, id|
      id_data << [id, c]
    end
    expect(id_data[0]).to eq [nil, [106, 1, 2, 103]]

    def link(v, r_id, c_id)
      "#{v}_#{r_id.to_i}_#{c_id.to_i}"
    end

    am.create_links!(method(:link))

    expect(am.row(0)[0]).to eq('106_0_0')
    expect(am.rows[-1][-1]).to eq('100_3_4')
  end
end

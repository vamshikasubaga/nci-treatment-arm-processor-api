

describe StatusPieData do

  let(:status_pie_data) do
    status_data = StatusPieData.new
    status_data.id = "EAY131-A"
    status_data.status_array = ["test", "test"]
    status_data
  end


  it "recieved from db" do
    ba = status_pie_data
    expect(ba.id).to be_kind_of(String)
    expect(ba.status_array).to be_kind_of(Array)
  end

end
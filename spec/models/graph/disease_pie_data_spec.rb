
describe DiseasePieData do

  let(:disease_pie_data) do
    disease_data = DiseasePieData.new
    disease_data.id = "EAY131-A"
    disease_data.disease_array = ["must be a array"]
    disease_data
  end


  it "recieved from db" do
    ba = disease_pie_data
    expect(ba.id).to eq("EAY131-A")
    expect(ba.disease_array).to eq(["must be a array"])
  end

  it "should be the correct data type" do
    ba = disease_pie_data
    expect(ba.id).to be_kind_of(String)
    expect(ba.disease_array).to be_kind_of(Array)
  end

end

class TreatmentArmConverter

  def initialize
    # p TreatmentArm.all.entries.map {|d| d.as_document}
    ta_json =  TreatmentArm.where(:_id => "EAY131-G").first.to_json
    ta = JSON.parse(ta_json)
    hash_proc = Proc.new { |k, v| v.kind_of?(Hash) ? (v.delete_if(&hash_proc); nil) : v.to_s.blank? }
    ta.delete_if(&hash_proc)
    ta["exclusionDrugs"].each do | drugs |
     drugs.each do | moreDrugs |
       moreDrugs[1].each do | fuckDrugs |
         fuckDrugs.delete_if(&hash_proc)
       end
     end
    end
    p ta
  end

end

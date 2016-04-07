class Hash

  def sort_hash_descending(data=self)
    if data.length <= 1
      data
    elsif data.is_a? Hash
      Hash[*data.sort.reverse.flatten]
    end
  end

end


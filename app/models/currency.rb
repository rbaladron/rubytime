class Currency
  include DataMapper::Resource
  
  PREFIX_REGEX = SUFFIX_REGEX = /^[^0-9]*$/
  
  property :id, Serial
  property :singular_name, String, :required => true
  property :plural_name,   String, :required => true
  property :prefix,        String
  property :suffix,        String
  
  validates_is_unique :singular_name, :plural_name
  validates_format :prefix, :with => PREFIX_REGEX, :if => proc { |c| not c.prefix.nil? }
  validates_format :suffix, :with => SUFFIX_REGEX, :if => proc { |c| not c.suffix.nil? }
  validates_with_method :singular_name, :method => :validates_singular_name_format
  validates_with_method :plural_name, :method => :validates_plural_name_format
  
  default_scope(:default).update(:order => [:singular_name])
  
  def render(value)
    "#{prefix}#{format('%.2f',value)}#{suffix}"
  end
  
  [:singular_name, :plural_name].each do |attr|
    define_method "validates_#{attr}_format" do
      if self.send(attr)=~ /^[\w ]*$/ && self.send(attr) !~ /[\d_]/
        true
      else
        [false, "#{attr.to_s.gsub(/_/, ' ').capitalize} has an invalid format."]
      end 
    end
  end
  
end

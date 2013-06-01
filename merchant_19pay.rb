require 'md5'
module Pay19
  class Merchant
    GATEWAY='https://pay.19pay.com/page/bussOrder.do'#  #http://114.255.7.208/page/bussOrder.do
    CONFIG={ :version_id =>'2.0',:merchant_id=>3333,:merchant_key=>"password",:currency=>'RMB'}
    ATTRIBUTES =[:order_date,:order_id,:amount,:returl,:notify_url,:pm_id,:pc_id,:order_pname,:order_pdesc,:user_name,:user_phone,:user_mobile,:user_email]
    ATTRS_REQUEST=[:version_id,:merchant_id,:order_date,:order_id,:amount,:currency,:returl,:pm_id,:pc_id,:merchant_key] 
    ATTRS_NOTIFY=[:version_id,:merchant_id,:order_id,:result,:order_date,:amount,:currency,:pay_sq,:pay_date,:pc_id,:merchant_key]
    attr_accessor *ATTRIBUTES
    #进行初始化
    def initialize(options={},&block)
      options.each{|k,v| send k.to_s + '=',v }
      yield(self) if block_given?
    end
    #返回URI
    def uri
      p = parameters.delete_if{|k,v| v.nil? || v ==''}
      p[:verifystring]=self.class.sign(ATTRS_REQUEST,p)
      GATEWAY + "?" + p.map{|k,v|k.to_s + "=" + v.to_s}.join('&')
    end
    #验证通知
    def self.notify_verify(options)
      options[:merchant_key]=CONFIG[:merchant_key]
      options[:verifystring].eql?(sign(ATTRS_NOTIFY,options))
    end
    private
    def parameters
      ATTRIBUTES.inject(CONFIG.dup){|m,a| m.merge(a=>(send a))}
    end
    def self.sign(attrs,options)
      Digest::MD5.hexdigest(attrs.map{|e| e.to_s + "=" + options[e].to_s}.join('&'))
    end
  end
end

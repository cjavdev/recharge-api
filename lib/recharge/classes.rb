require "json"
require "class2"
require "recharge/http_request"

class2 "Recharge", JSON.parse(<<-END) do
{
  "subscription":
     {
        "id":10101,
        "address_id":178918,
        "customer_id":1438,
        "created_at":"2017-02-28T20:31:29",
        "updated_at":"2017-02-28 20:31:29",
        "next_charge_scheduled_at":"2017-04-01T00:00:00",
        "cancelled_at":null,
        "product_title":"Sumatra Coffee",
        "price":12,
        "quantity":1,
        "status":"ACTIVE",
        "shopify_product_id":1255183683,
        "shopify_variant_id":3844924611,
        "sku":null,
        "order_interval_unit":"day",
        "order_interval_frequency":"30",
        "charge_interval_frequency":"30",
        "order_day_of_month":null,
        "order_day_of_week":null,
        "properties": []
     },
  "charge":
    {
      "address_id":178918,
      "billing_address":{
         "address1":"3030 Nebraska Avenue",
         "address2":"",
         "city":"Los Angeles",
         "company":"",
         "country":"United States",
         "first_name":"Mike",
         "last_name":"Flynn",
         "phone":"",
         "province":"California",
         "zip":"90404"
      },
      "client_details": {
        "browser_ip": null,
        "user_agent": null
      },
      "created_at":"2017-03-01T19:52:11",
      "customer_hash":null,
      "customer_id":10101,
      "first_name":"Mike",
      "id":1843,
      "last_name":"Flynn",
      "line_items":[
         {
            "grams":0,
            "price":100.0,
            "properties":[],
            "quantity":1,
            "shopify_variant_id":"3844924611",
            "sku":"",
            "subscription_id":14562
         }
      ],
      "processed_at":"2014-11-20T00:00:00",
      "scheduled_at":"2014-11-20T00:00:01",
      "shipments_count":null,
      "shipping_address":{
         "address1":"3030 Nebraska Avenue",
         "address2":"",
         "city":"Los Angeles",
         "company":"",
         "country":"United States",
         "first_name":"Mike",
         "last_name":"Flynn",
         "phone":"3103843698",
         "province":"California",
         "zip":"90404"
      },
      "shopify_order_id":"281223307",
      "status":"SUCCESS",
      "total_price":446.00,
      "updated_at":"2016-09-05T09:19:29"
    },
  "customer":
     {
        "id": 1438,
        "hash": "143806234a9ff87a8d9e",
        "shopify_customer_id": null,
        "email": "mike@gmail.com",
        "created_at": "2018-01-10T11:00:00",
        "updated_at": "2017-01-11T13:16:19",
        "first_name": "Mike",
        "last_name": "Flynn",
        "billing_first_name": "Mike",
        "billing_last_name": "Flynn",
        "billing_company": null,
        "billing_address1": "3030 Nebraska Avenue",
        "billing_address2": null,
        "billing_zip": "90404",
        "billing_city": "Los Angeles",
        "billing_province": "California",
        "billing_country": "United States",
        "billing_phone": "3103843698",
        "processor_type": null,
        "status": "FOO"
    },
  "order": {
     "id":7271806,
     "customer_id":10101,
     "address_id":178918,
     "charge_id":9519316,
     "transaction_id":"ch_19sdP2J2zqHvZRd1hqkeGANO",
     "shopify_order_id":"5180645510",
     "shopify_order_number":5913,
     "created_at":"2017-03-01T14:46:26",
     "updated_at":"2017-03-01T14:46:26",
     "scheduled_at":"2017-03-01T00:00:00",
     "processed_at":"2017-03-01T14:46:26",
     "status":"SUCCESS",
     "charge_status":"SUCCESS",
     "type":"CHECKOUT",
     "first_name":"Mike",
     "last_name":"Flynn",
     "email":"mike@gmail.com",
     "payment_processor":"stripe",
     "address_is_active":1,
     "is_prepaid":0,
     "line_items":[
        {
           "subscription_id":10101,
           "shopify_product_id":"1255183683",
           "shopify_variant_id":"3844924611",
           "variant_title":"Sumatra",
           "title":"Sumatra Latte",
           "quantity":1,
           "properties":[]
        }
     ],
     "total_price":18.00,
     "shipping_address":{
        "address1":"1933 Manning",
        "address2":"204",
        "city":"los angeles",
        "province":"California",
        "first_name":"mike",
        "last_name":"flynn",
        "zip":"90025",
        "company":"bootstrap",
        "phone":"3103103101",
        "country":"United States"
     },
     "billing_address":{
        "address1":"1933 Manning",
        "address2":"204",
        "city":"los angeles",
        "province":"California",
        "first_name":"mike",
        "last_name":"flynn",
        "zip":"90025",
        "company":"bootstrap",
        "phone":"3103103101",
        "country":"United States"
     }
  },
  "webhook":
    {
        "id":6,
        "address":"https://request.in/foo",
        "topic":"order/create"
  },
  "address":{
    "id":3411137,
    "address1":"1933 Manning",
    "address2":"204",
    "city":"los angeles",
    "province":"California",
    "first_name":"mike",
    "last_name":"flynn",
    "zip":"90025",
    "company":"bootstrap",
    "phone":"3103103101",
    "country":"United States"
  }
}
END
  def meta=(meta)
    @meta = meta
  end

  def meta
    @meta ||= {}
  end
end

module Recharge
  module Persistable  # :nodoc:
    def save
      if id
        self.class.update(id, to_h)
      else
        self.id = self.class.create(to_h).id
      end
    end
  end

  class Address
    PATH = "/addresses".freeze
    SINGLE = "address".freeze
    COLLECTION = "addresses".freeze

    extend HTTPRequest::Get
    extend HTTPRequest::Update

    def save
      self.class.update(id, to_h)
    end

    # Validate an address
    #
    # === Arguments
    #
    # [data (Hash)] Address to validate, see: https://developer.rechargepayments.com/?shell#validate-address
    #
    # === Errors
    #
    # Recharge::ConnectionError, Recharge::RequestError
    #
    # If the address is invalid a Recharge::RequestError is raised. The validation
    # errors can be retrieved via Recharge::RequestError#errors
    #
    # === Returns
    #
    # [Hash] Validated and sometimes updated address
    #
    def self.validate(data)
      POST(join("validate"), data)
    end
  end

  class Customer
    PATH = "/customers".freeze
    SINGLE = "customer".freeze
    COLLECTION = "customers".freeze

    extend HTTPRequest::Create
    extend HTTPRequest::Get
    extend HTTPRequest::Update
    extend HTTPRequest::List
    extend HTTPRequest::Count

    include Persistable

    # Retrieve all of a customer's addresses
    #
    # === Arguments
    #
    # [id (Fixnum)] Customer ID
    #
    # === Errors
    #
    # ConnectionError, RequestError
    #
    # === Returns
    #
    # [Array[Recharge::Address]] The customer's addresses
    #
    def self.addresses(id)
      id_required!(id)
      (GET(join(id, Address::COLLECTION))[Address::COLLECTION] || []).map { |data| Address.new(data) }
    end

    # Create a new address
    #
    # === Arguments
    #
    # [id (Fixnum)] Customer ID
    # [address (Hash)] Address attributes, see: https://developer.rechargepayments.com/?shell#create-address
    #
    # === Errors
    #
    # Recharge::ConnectionError, Recharge::RequestError
    #
    # === Returns
    #
    # [Recharge::Address] The created address
    #
    def self.create_address(id, address)
      id_required!(id)
      Address.new(POST(join(id, Address::COLLECTION), address)[Address::SINGLE])
    end
  end

  class Charge
    PATH = "/charges".freeze
    SINGLE = "charge".freeze
    COLLECTION = "charges".freeze

    extend HTTPRequest::Count
    extend HTTPRequest::Get
    extend HTTPRequest::List

    def self.list(options = nil)
      super(convert_date_params(options, :date_min, :date_max))
    end

    def self.change_next_charge_date(id, date)
      path = join(id, "change_next_charge_date")
      POST(path, :next_charge_date => date_param(date))[SINGLE].map { |data| new(data) }
    end

    def self.skip(id, subscription_id)
      path = join(id, "skip")
      POST(path, :subscription_id => subscription_id)[SINGLE].map { |data| new(data) }
    end
  end

  class Order
    PATH = "/orders".freeze
    SINGLE = "order".freeze
    COLLECTION = "orders".freeze

    extend HTTPRequest::Count
    extend HTTPRequest::Get
    extend HTTPRequest::List

    def self.count(options = nil)
      super(convert_date_params(options, :created_at_max, :created_at_min, :date_min, :date_max))
    end

    def self.change_date(id, date)
      id_required!(id)
      new(POST(join(id, "change_date"), :shipping_date => date_param(date))[SINGLE])
    end

    def self.update_shopify_variant(id, old_variant_id, new_varient_id)
      path = join(id, "update_shopify_variant", old_variant_id)
      new(POST(path, :new_shopify_variant_id => new_varient_id)[SINGLE])
    end
  end

  class Subscription
    PATH = "/subscriptions".freeze
    SINGLE = "subscription".freeze
    COLLECTION = "subscriptions".freeze

    extend HTTPRequest::Create
    extend HTTPRequest::Get
    extend HTTPRequest::Update
    extend HTTPRequest::List

    include Persistable

    def self.activate(id)
      # TODO: same response as cancel?
      id_required!(id)
      new(POST(join(id, "activate")))
    end

    def self.cancel(id, reason)
      # TODO: check response structure, e.g., "message" param not def'd in Subscription
      new(POST(join(id, "cancel"), :cancellation_reason => reason))
    end

    def self.set_next_charge_date(id, date)
      POST(join(id, "set_next_charge_date"), :date => date_param(date))[SINGLE]
    end

    def self.list(options = nil)
      #options[:status] = options[:status].upcase if options[:status]
      super(convert_date_params(:created_at, :created_at_max, :updated_at, :updated_at_max))
    end
  end

  class Webhook
    PATH = "/webhooks".freeze
    COLLECTION = "webhooks".freeze
    SINGLE = "webhook".freeze

    extend HTTPRequest::Create
    extend HTTPRequest::Delete
    extend HTTPRequest::Get
    extend HTTPRequest::List
    extend HTTPRequest::Update

    include Persistable

    def delete
      self.class.delete(id)
      true
    end
  end
end
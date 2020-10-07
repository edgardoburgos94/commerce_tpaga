class PaymentService
	VALIDITY = 5.days

	class PaymentServiceError < StandardError; end
	
	def create_payment_request(order)
		url = "#{ENV['TPAGA_API_URL']}/merchants/api/v1/payment_requests/create"
		payload = build_payload(order)

		response = HTTParty.post(
			url,
			body: payload,
			headers: default_headers
		)

		response.code == 201 ? JSON.parse(response.body) : raise_exception(response)
	end

	private

	def build_payload(order)
		{
			cost: order.cost.to_i,
			purchase_details_url: "#{ENV['COMMERCE_URL']}/compra/#{order.id}",
			voucher_url: "#{ENV['COMMERCE_URL']}/comprobante/#{order.id}",
			idempotency_token: SecureRandom.uuid,
			order_id: order.id,
			terminal_id: "sede_45",
			purchase_description: "Compra en Tienda X",
			purchase_items: order.items.map{ |item| { name: item.name, value: item.cost }},
			user_ip_address: order.user_ip_address,
			expires_at: expiration_date
		}.to_json
	end

	def expiration_date
		(DateTime.now + 5.days).iso8601(3)
	end

	def default_headers
		{ 
			'Authorization' => "Basic #{encoded_aut_key}",
			'Cache-Control' => 'no-cache',
			'Content-Type' => 'application/json'
		}
	end

	def encoded_aut_key
		name = ENV['TPAGA_USERNAME']
		password = ENV['TPAGA_PASSWORD']

		Base64.strict_encode64("#{name}:#{password}")
	end

	def raise_exception(response)
		exception_message = "#{response.message}: #{response.body}"

		raise PaymentServiceError, exception_message
	end
end
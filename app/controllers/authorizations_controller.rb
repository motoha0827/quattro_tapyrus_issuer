class AuthorizationsController < ActionController::Base
  protect_from_forgery

  def index
    transaction = params[:transaction]
    did = Did.find_by(did_long_form: transaction[:did])
    wallet = did.wallet
    authorization = wallet.balance >= transaction[:amount]

    did_verification = params[:didVerification]
    message_digest = did_verification[:messageDigest]
    nonce = did_verification[:nonce]
    params_json = {
      "messageDigest": message_digest,
      "nonce": nonce,
      "signingKey": JSON.parse(did.signing_key)
    }.to_json

    response = Net::HTTP.post(
      URI('http://localhost:3001/did/signature'),
      params_json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)
    signature = body['signature']
    return_json = {
      authorization:,
      signature:
    }
    render json: return_json
  end
end

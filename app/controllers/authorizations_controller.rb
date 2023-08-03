class AuthorizationsController < ActionController::Base
  protect_from_forgery

  def index
    # オーソリ要求から電文部分を取得する
    transaction = params[:transaction]
    did = Did.find_by(did_long_form: transaction[:did])
    wallet = did.wallet

    # 残高に応じてオーソリを判断する
    authorization = wallet.balance >= transaction[:amount]

    # DID Verify 部分を取得する
    did_verification = params[:didVerification]
    message_digest = did_verification[:messageDigest]
    nonce = did_verification[:nonce]

    # DID Service へ signature の作成要求を送る
    params_json = {
      "messageDigest": message_digest,
      "nonce": nonce,
      "signingKey": JSON.parse(did.signing_key)
    }.to_json
    response = Net::HTTP.post(
      URI("#{ENV['DID_SERVICE_URL']}/did/signature"),
      params_json,
      'Content-Type' => 'application/json'
    )

    # 返答から signature を受け取る
    body = JSON.parse(response.body)
    signature = body['signature']

    # オーソリ認否、signature を返す
    return_json = {
      authorization:,
      signature:
    }

    render json: return_json
  end
end

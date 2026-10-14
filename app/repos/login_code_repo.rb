# frozen_string_literal: true

module Rounds
  module Repos
    class LoginCodeRepo < Rounds::DB::Repo
      def replace(user_id, digest, expires_at)
        db[:login_codes].where(user_id: user_id).delete
        db[:login_codes].insert(user_id: user_id, digest: digest, expires_at: expires_at, created_at: now)
      end

      def latest(user_id)
        db[:login_codes].where(user_id: user_id).order(Sequel.desc(:id)).first
      end

      def recent_count(user_id, since)
        db[:login_codes].where(user_id: user_id).where { created_at >= since }.count
      end

      def add_attempt(id)
        db[:login_codes].where(id: id).update(attempts: Sequel[:attempts] + 1)
      end

      def delete_for(user_id)
        db[:login_codes].where(user_id: user_id).delete
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe UserGames::ProcessCatapultAttackCommand do
  subject { command.call }

  let(:from_user) { create(:user) }
  let(:to_user) { create(:user) }
  let(:game) { create(:game) }
  let(:vikings_civilization) { Civilization.find_by!(key: 'vikings') }
  let(:chinese_civilization) { Civilization.find_by!(key: 'chinese') }
  let(:attacker_user_game) do
    UserGames::CreateCommand.new(current_user: from_user, game: game, civilization: vikings_civilization).call
  end
  let(:defender_user_game) do
    UserGames::CreateCommand.new(current_user: to_user, game: game, civilization: chinese_civilization).call
  end
  let(:attack_queue) do
    create(:attack_queue, game: game, user_game: attacker_user_game, to_user_game: defender_user_game,
           attack_status: :done_fighting, attack_type: attack_type, catapult_soldiers: 100)
  end
  let(:command) do
    described_class.new(
      user_game: attacker_user_game,
      data: PrepareDataCommand.new(user_game: attacker_user_game).call,
      attack_queue: attack_queue,
    )
  end
  let(:attack_type) { :catapult_army_and_towers }

  describe '#execute' do
    before do
      defender_user_game.update!(catapult_soldiers: 25)
    end

    it 'returns attack log' do
      old_catapult_soldiers = attack_queue.catapult_soldiers
      old_defender_catapult_soldiers = defender_user_game.catapult_soldiers

      result = subject

      expect(result[:attacker_wins]).to be_truthy
      expect(result[:attack_log]).to be_present
      expect(command.errors).to be_blank

      attack_queue.reload
      defender_user_game.reload

      expect(attack_queue.catapult_soldiers < old_catapult_soldiers).to be_truthy
      expect(defender_user_game.catapult_soldiers < old_defender_catapult_soldiers).to be_truthy
    end

    context 'when lose the attack' do
      before do
        defender_user_game.update!(catapult_soldiers: 500)
      end

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_falsey
        expect(result[:attack_log]).to be_present
        expect(command.errors).to be_blank
      end
    end

    context 'when attack_type is catapult_population' do
      let(:attack_type) { :catapult_population }
      let(:people) { 10_000 }

      before do
        defender_user_game.update!(people: people)
      end

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_truthy
        expect(result[:attack_log]).to be_present
        expect(result[:stolen_resources]).to be_blank
        expect(command.errors).to be_blank

        defender_user_game.reload
        expect(defender_user_game.people < people).to be_truthy
      end
    end

    context 'when attack_type is catapult_buildings' do
      let(:attack_type) { :catapult_buildings }

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_truthy
        expect(result[:attack_log]).to be_present
        expect(result[:stolen_resources]).to be_blank
        expect(command.errors).to be_blank
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe BuildQueues::CreateCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end

  # hunter: forest land, squares: 2, cost_gold: 25, cost_wood: 4, cost_iron: 0
  let(:build_params) do
    {
      building_queue_type: 'build',
      building_type: 'hunter',
      building_quantity: '5'
    }
  end

  let(:demolish_params) do
    {
      building_queue_type: 'demolish',
      building_type: 'hunter',
      building_quantity: '2'
    }
  end

  def make_command(params)
    described_class.new(user_game: user_game, build_queue_params: params)
  end

  describe '#call' do
    context 'build queue type' do
      context 'with valid params and sufficient resources' do
        it 'returns true' do
          expect(make_command(build_params).call).to be true
        end

        it 'creates a build queue record' do
          expect { make_command(build_params).call }
            .to change { user_game.build_queues.count }.by(1)
        end

        it 'sets the build queue type to build' do
          make_command(build_params).call
          expect(user_game.build_queues.last.queue_type).to eq('build')
        end

        it 'deducts gold and wood from user_game' do
          # hunter x5: gold=25*5=125, wood=4*5=20
          original_gold = user_game.gold
          original_wood = user_game.wood
          make_command(build_params).call
          user_game.reload
          expect(user_game.gold).to eq(original_gold - 125)
          expect(user_game.wood).to eq(original_wood - 20)
        end

        it 'stores resource costs on the build queue' do
          make_command(build_params).call
          queue = user_game.build_queues.last
          expect(queue.gold).to eq(125)
          expect(queue.wood).to eq(20)
          expect(queue.iron).to eq(0)
        end

        it 'has no errors' do
          command = make_command(build_params)
          command.call
          expect(command.errors).to be_empty
        end
      end

      context 'with blank building type' do
        it 'adds an error' do
          command = make_command(build_params.merge(building_type: ''))
          command.call
          expect(command.errors).to include('Invalid building to build.')
        end

        it 'does not create a build queue' do
          expect { make_command(build_params.merge(building_type: '')).call }
            .not_to change { user_game.build_queues.count }
        end
      end

      context 'with an unrecognised building type' do
        it 'adds an error' do
          command = make_command(build_params.merge(building_type: 'nonexistent'))
          command.call
          expect(command.errors).to include('Invalid building to build.')
        end
      end

      context 'with zero quantity' do
        it 'adds an error' do
          command = make_command(build_params.merge(building_quantity: '0'))
          command.call
          expect(command.errors).to include('Invalid number of buildings.')
        end
      end

      context 'with negative quantity' do
        it 'adds an error' do
          command = make_command(build_params.merge(building_quantity: '-3'))
          command.call
          expect(command.errors).to include('Invalid number of buildings.')
        end
      end

      context 'with insufficient gold' do
        before { user_game.update!(gold: 10) }

        it 'adds an error' do
          command = make_command(build_params)
          command.call
          expect(command.errors.first).to include('enough gold')
        end

        it 'does not create a build queue' do
          expect { make_command(build_params).call }
            .not_to change { user_game.build_queues.count }
        end

        it 'does not change resources' do
          original_gold = user_game.gold
          make_command(build_params).call
          user_game.reload
          expect(user_game.gold).to eq(original_gold)
        end
      end

      context 'with insufficient wood' do
        before { user_game.update!(wood: 0) }

        it 'adds an error' do
          command = make_command(build_params)
          command.call
          expect(command.errors.first).to include('enough wood')
        end

        it 'does not create a build queue' do
          expect { make_command(build_params).call }
            .not_to change { user_game.build_queues.count }
        end
      end

      context 'with insufficient iron' do
        # gold_mine: mountain, cost_gold: 1000, cost_wood: 10, cost_iron: 10
        let(:gold_mine_params) do
          { building_queue_type: 'build', building_type: 'gold_mine', building_quantity: '1' }
        end

        before { user_game.update!(iron: 0) }

        it 'adds an error' do
          command = make_command(gold_mine_params)
          command.call
          expect(command.errors.first).to include('enough iron')
        end
      end

      context 'with insufficient forest land' do
        before { user_game.update!(f_land: 0) }

        it 'adds an error about land' do
          command = make_command(build_params)
          command.call
          expect(command.errors.first).to match(/free land/i)
        end

        it 'does not create a build queue' do
          expect { make_command(build_params).call }
            .not_to change { user_game.build_queues.count }
        end
      end

      context 'with insufficient mountain land' do
        # iron_mine: mountain, squares: 2, cost_gold: 100, cost_wood: 6, cost_iron: 0
        let(:iron_mine_params) do
          { building_queue_type: 'build', building_type: 'iron_mine', building_quantity: '1' }
        end

        before { user_game.update!(m_land: 0) }

        it 'adds a land error' do
          command = make_command(iron_mine_params)
          command.call
          expect(command.errors.first).to match(/free land/i)
        end
      end
    end

    context 'demolish queue type' do
      context 'with valid params' do
        it 'returns true' do
          expect(make_command(demolish_params).call).to be true
        end

        it 'creates a demolish queue record' do
          expect { make_command(demolish_params).call }
            .to change { user_game.build_queues.where(queue_type: :demolish).count }.by(1)
        end

        it 'does not deduct resources' do
          original_gold = user_game.gold
          make_command(demolish_params).call
          user_game.reload
          expect(user_game.gold).to eq(original_gold)
        end

        it 'has no errors' do
          command = make_command(demolish_params)
          command.call
          expect(command.errors).to be_empty
        end
      end

      context 'with quantity 0' do
        it 'adds an error' do
          command = make_command(demolish_params.merge(building_quantity: '0'))
          command.call
          expect(command.errors).to include('Cannot demolish 0 buildings.')
        end
      end

      context 'with quantity exceeding available buildings' do
        it 'adds an error' do
          # user_game has hunter: 50, requesting 999
          command = make_command(demolish_params.merge(building_quantity: '999'))
          command.call
          expect(command.errors).to include('You do not have that many buildings of this type.')
        end
      end

      context 'when already demolishing reduces available count' do
        before do
          # Queue up 48 demolitions; user_game has hunter: 50, so only 2 remain
          user_game.build_queues.create!(
            building_type: :hunter,
            queue_type: :demolish,
            quantity: 48,
            position: 1,
            turn_added: 0,
            time_needed: 10
          )
        end

        it 'prevents over-demolishing' do
          # 50 total - 48 in queue = 2 available, requesting 3
          command = make_command(demolish_params.merge(building_quantity: '3'))
          command.call
          expect(command.errors).to include('You do not have that many buildings of this type.')
        end
      end
    end

    context 'with an unknown queue type' do
      let(:unknown_params) do
        { building_queue_type: 'unknown', building_type: 'hunter', building_quantity: '1' }
      end

      it 'returns true' do
        expect(make_command(unknown_params).call).to be true
      end

      it 'does not create any queue' do
        expect { make_command(unknown_params).call }
          .not_to change { user_game.build_queues.count }
      end

      it 'has no errors' do
        command = make_command(unknown_params)
        command.call
        expect(command.errors).to be_empty
      end
    end
  end
end

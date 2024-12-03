// define the interface
#[starknet::interface]
trait IActions<T> {
    fn spawn(ref self: T);
    fn move(ref self: T, direction: Direction);
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions, Direction, Position, next_position};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Vec2, DirectionsAvailable};
    use dojo_starter::models::{PlayerLevel};
    use dojo_starter::models::{Points};
    use dojo_starter::models::{Skills};
    use dojo_starter::models::{Moves};


    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Moved {
        #[key]
        pub player: ContractAddress,
        pub direction: Direction,
        pub steps_remaining: u64,
    }
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct LevelUnlocked {
        #[key]
        pub player: ContractAddress,
        pub level: u64,
    }
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct PointCollected {
        #[key]
        pub player: ContractAddress,
        pub new_total: u64,
    }
    #[derive(Copy, Drop, Serde, PartialEq, Debug)]
    pub enum SkillType {
        Water,
        Fire,
        Electric,
    }
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ScoreCalculated {
        #[key]
        pub player: ContractAddress,
        pub score: u64,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(ref self: ContractState) {
            // Get the default world.
            let mut world = self.world_default();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();
            // Retrieve the player's current position from the world.
            let position: Position = world.read_model(player);

            // Move the player's position 10 units in both the x and y direction.
            let new_position = Position {
                player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
            };

            let points = Points { player, total_points: 0, };
            world.write_model(@points);
            // Write the new position to the world.
            world.write_model(@new_position);
            let level = PlayerLevel { player, level: 1, // Starting at level 1
             };
            world.write_model(@level);

            // 2. Set the player's remaining moves to 100.
            let moves = Moves {
                player,
                remaining: 100,
                last_direction: Direction::None(()),
                can_move: true,
                steps_moved: 0,
            };

            // Write the new moves to the world.
            world.write_model(@moves);
            // Initialize player skills
            let skills = Skills { player, has_water: false, has_fire: false, has_electric: false, };
            world.write_model(@skills);
        }

        // Implementation of the move function for the ContractState struct.
        fn move(ref self: ContractState, direction: Direction) {
            // Gets the address of the current caller, possibly the player's address.

            let mut world = self.world_default();

            let player = get_caller_address();

            // Retrieves the player's current position and moves data from the world.
            let position: Position = world.read_model(player);
            let mut moves: Moves = world.read_model(player);

            // Deducts one from the player's remaining moves.
            moves.remaining -= 1;

            //Steps moved by player.
            moves.steps_moved += 1;

            // Updates the last direction the player moved in.
            moves.last_direction = direction;

            // Calculates the player's next position based on the provided direction.
            let next = next_position(position, direction);

            // Writes the new position to the world.
            world.write_model(@next);

            // Writes the new moves to the world.
            world.write_model(@moves);

            // Emits an event to the world to notify about the player's move.
            world.emit_event(@Moved { player, direction, steps_remaining: moves.remaining });
        }
    }
    fn unlock_next_level(ref self: ContractState, level: PlayerLevel) {
        // Gets the address of the current caller, possibly the player's address.

        let mut world = self.world_default();

        let player = get_caller_address();
        let mut level: PlayerLevel = world.read_model(player);
        // Increments the player's level

        level.level += 1;
        world.write_model(@level);

        world.emit_event(@LevelUnlocked { player, level: level.level });
    }
    fn collect_coin(ref self: ContractState) {
        let mut world = self.world_default();

        let player = get_caller_address();

        // Reads the player's current points
        let mut points: Points = world.read_model(player);

        // Increments the player's points
        points.total_points += 5;

        // Writes the updated points back to the world
        world.write_model(@points);

        //  emits an event
        world.emit_event(@PointCollected { player, new_total: points.total_points, });
    }

    fn acquire_skill(ref self: ContractState, skill: SkillType) {
        let mut world = self.world_default();
        let player = get_caller_address();

        // Retrieve the player's current skills
        let mut skills: Skills = world.read_model(player);

        // Update the skill based on the input
        match skill {
            SkillType::Water => skills.has_water = true,
            SkillType::Fire => skills.has_fire = true,
            SkillType::Electric => skills.has_electric = true,
        }

        // Write the updated skills back to the world
        world.write_model(@skills);
    }
    fn loose_skill(ref self: ContractState, skill: SkillType) {
        let mut world = self.world_default();
        let player = get_caller_address();

        // Retrieve the player's current skills
        let mut skills: Skills = world.read_model(player);

        // Update the skill based on the input
        match skill {
            SkillType::Water => skills.has_water = false,
            SkillType::Fire => skills.has_fire = false,
            SkillType::Electric => skills.has_electric = false,
        }

        // Write the updated skills back to the world
        world.write_model(@skills);
    }
    fn calculate_score(ref self: ContractState) -> u64 {
        let mut world = self.world_default();
        let player = get_caller_address();

        // Retrieve the player's moves and points
        let moves: Moves = world.read_model(player);
        let points: Points = world.read_model(player);

        // Calculate the score
        let score = moves.remaining + points.total_points;

        world.emit_event(@ScoreCalculated { player, score, });

        score
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "dojo_starter". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"dojo_starter")
        }
    }
}

// Define function like this:
fn next_position(mut position: Position, direction: Direction) -> Position {
    match direction {
        Direction::None => { return position; },
        Direction::Left => { position.vec.x -= 1; },
        Direction::Right => { position.vec.x += 1; },
        Direction::Up => { position.vec.y -= 1; },
        Direction::Down => { position.vec.y += 1; },
    };
    position
}

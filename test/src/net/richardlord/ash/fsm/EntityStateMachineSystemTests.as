package net.richardlord.ash.fsm
{
	import asunit.asserts.fail;
	import asunit.framework.IAsync;

	import net.richardlord.ash.core.Entity;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.sameInstance;

	public class EntityStateMachineSystemTests
	{
		[Inject]
		public var async : IAsync;

		private var fsm : EntityStateMachine;
		private var entity : Entity;
		private var system : EntityStateMachineSystem;
		private var node : EntityStateMachineNode;

		[Before]
		public function createState() : void
		{
			entity = new Entity();
			fsm = new EntityStateMachine();
			system = new EntityStateMachineSystem();
			node = new EntityStateMachineNode();
			node.entity = entity;
			node.stateMachine = fsm;
		}

		[After]
		public function clearState() : void
		{
			entity = null;
			fsm = null;
			system = null;
			node = null;
		}

		[Test]
		public function enterStateAddsStatesComponents() : void
		{
			var state : EntityState = new EntityState();
			var component : MockComponent = new MockComponent();
			state.add( MockComponent ).withInstance( component );
			fsm.addState( "test", state );
			fsm.changeState( "test" );
			system.updateNode( node, 0.1 );
			assertThat( entity.get( MockComponent ), sameInstance( component ) );
		}

		[Test]
		public function enterSecondStateAddsSecondStatesComponents() : void
		{
			var state1 : EntityState = new EntityState();
			var component1 : MockComponent = new MockComponent();
			state1.add( MockComponent ).withInstance( component1 );
			fsm.addState( "test1", state1 );
			fsm.changeState( "test1" );
			system.updateNode( node, 0.1 );

			var state2 : EntityState = new EntityState();
			var component2 : MockComponent2 = new MockComponent2();
			state2.add( MockComponent2 ).withInstance( component2 );
			fsm.addState( "test2", state2 );
			fsm.changeState( "test2" );
			system.updateNode( node, 0.1 );

			assertThat( entity.get( MockComponent2 ), sameInstance( component2 ) );
		}

		[Test]
		public function enterSecondStateRemovesFirstStatesComponents() : void
		{
			var state1 : EntityState = new EntityState();
			var component1 : MockComponent = new MockComponent();
			state1.add( MockComponent ).withInstance( component1 );
			fsm.addState( "test1", state1 );
			fsm.changeState( "test1" );
			system.updateNode( node, 0.1 );

			var state2 : EntityState = new EntityState();
			var component2 : MockComponent2 = new MockComponent2();
			state2.add( MockComponent2 ).withInstance( component2 );
			fsm.addState( "test2", state2 );
			fsm.changeState( "test2" );
			system.updateNode( node, 0.1 );

			assertThat( entity.has( MockComponent ), isFalse() );
		}

		[Test]
		public function enterSecondStateDoesNotRemoveOverlappingComponents() : void
		{
			entity.componentRemoved.add( failIfCalled );
			
			var state1 : EntityState = new EntityState();
			var component1 : MockComponent = new MockComponent();
			state1.add( MockComponent ).withInstance( component1 );
			fsm.addState( "test1", state1 );
			fsm.changeState( "test1" );
			system.updateNode( node, 0.1 );

			var state2 : EntityState = new EntityState();
			var component2 : MockComponent2 = new MockComponent2();
			state2.add( MockComponent ).withInstance( component1 );
			state2.add( MockComponent2 ).withInstance( component2 );
			fsm.addState( "test2", state2 );
			fsm.changeState( "test2" );
			system.updateNode( node, 0.1 );

			assertThat( entity.get( MockComponent ), sameInstance( component1 ) );
		}

		[Test]
		public function enterSecondStateRemovesDifferentComponentsOfSameType() : void
		{
			var state1 : EntityState = new EntityState();
			var component1 : MockComponent = new MockComponent();
			state1.add( MockComponent ).withInstance( component1 );
			fsm.addState( "test1", state1 );
			fsm.changeState( "test1" );
			system.updateNode( node, 0.1 );

			var state2 : EntityState = new EntityState();
			var component3 : MockComponent = new MockComponent();
			var component2 : MockComponent2 = new MockComponent2();
			state2.add( MockComponent ).withInstance( component3 );
			state2.add( MockComponent2 ).withInstance( component2 );
			fsm.addState( "test2", state2 );
			fsm.changeState( "test2" );
			system.updateNode( node, 0.1 );

			assertThat( entity.get( MockComponent ), sameInstance( component3 ) );
		}

		private static function failIfCalled( ...args ) : void
		{
			fail( "Component was removed when it shouldn't have been." );
		}
	}
}

class MockComponent
{
	public var value : int;
}

class MockComponent2
{
	public var value : String;
}

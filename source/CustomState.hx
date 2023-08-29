package;

class CustomState extends MusicBeatState
{
	var state:String;
	var stateScript:HScript;

    override public function new(state:String) {
        super();

        this.state = state;
    }

	override public function create()
	{
		super.create();

		#if sys
		stateScript = new HScript('states/$state');
		if (!stateScript.isBlank && stateScript.expr != null)
		{
			stateScript.interp.scriptObject = this;
			stateScript.setValue('add', add);
			stateScript.interp.execute(stateScript.expr);
		}

		stateScript.callFunction('create');
		#end
	}

    override public function update(elapsed:Float) {
        super.update(elapsed);

        #if sys
        stateScript.callFunction('update', [elapsed]);
        #end
    }

    override public function stepHit() {
        #if sys
        stateScript.callFunction('stepHit');
        #end
    }

    override public function beatHit() {
        #if sys
        stateScript.callFunction('beatHit');
        #end
    }
}
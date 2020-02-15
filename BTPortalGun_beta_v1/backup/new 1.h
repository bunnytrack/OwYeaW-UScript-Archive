		else if( Other.IsA('Projectile') )
		{
			bTouched = true;
			ExitRotation = Brother.Rotation;
			ExitRotation.Roll = 0;
			Other.SetRotation(ExitRotation);
			Other.SetLocation(Brother.Location + Vector(Brother.Rotation) * 20 + vect(0,0,0) + Velocity * 0.01);
			Other.Velocity = Vsize(Other.Velocity) * Vector(Brother.Rotation);
			if( Other.IsA('GuidedWarshell') )
				GuidedWarShellRotation(GuidedWarshell(Other));
		}
function [] = notify()

% inform user it's done
soundName = 'gong'; % train, splat, chirp, gong, handel, laughter
sound(getfield(load(soundName), 'y'))

end

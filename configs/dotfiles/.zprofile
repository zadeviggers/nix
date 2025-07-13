echo 
echo !!!! CHICKEN JOCKEY !!!!
echo 

eval "$(/opt/homebrew/bin/brew shellenv)"
export LDFLAGS="-L/opt/homebrew/opt/ffmpeg@6/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ffmpeg@6/include"
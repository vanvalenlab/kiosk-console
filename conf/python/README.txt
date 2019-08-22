To run in debian container

git clone https://www.github.com/vanvalenlab/kiosk
cd conf
cd python
docker build -t gui .
docker run -it --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --env="DISPLAY" --volume="/run/user/1000/gdm/Xauthority:/run/user/1000/gdm/Xauthority:rw" --env="XAUTHORITY" --net=host --name kiosk-gui-test gui:latest
python3 main.py

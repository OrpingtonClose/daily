curl https://query.yahooapis.com/v1/public/yql    -d q="select wind from weather.forecast where woeid in (select woeid from geo.places(1) where text='warsaw, pl')" -d format=json

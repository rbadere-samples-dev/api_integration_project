import json
import requests
import os

def lambda_handler(event, context):
    try:
        # Debugging: Log the received event
        print("Received event:", json.dumps(event))

        # Extract city from Snowflake's request format
        body = json.loads(event.get("body", "{}"))
        city = body.get("data", [[0, "London"]])[0][1]  # Default to "London" if missing

        api_key = os.getenv("OPENWEATHER_API_KEY")
        if not api_key:
            return {
                "statusCode": 200,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({
                    "data": [
                        [0, {
                            "city_name": "API key is missing",
                            "temperature": None,
                            "weather_description": None,
                            "wind_speed": None
                        }]
                    ]
                })
            }

        # Call OpenWeather API
        url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
        response = requests.get(url)
        weather_data = response.json()

        # Format response
        formatted_data = {
            "data": [
                [0, {
                    "city_name": weather_data.get("name", "Unknown City"),
                    "temperature": weather_data.get("main", {}).get("temp", None),
                    "weather_description": weather_data.get("weather", [{}])[0].get("description", None),
                    "wind_speed": weather_data.get("wind", {}).get("speed", None)
                }]
            ]
        }

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(formatted_data)
        }

    except Exception as e:
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "data": [
                    [0, {
                        "error": str(e),
                        "city_name": None,
                        "temperature": None,
                        "weather_description": None,
                        "wind_speed": None
                    }]
                ]
            })
        }

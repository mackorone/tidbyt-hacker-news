load("http.star", "http")
load("time.star", "time")
load("render.star", "render")


TOP_STORIES_URL = "https://hacker-news.firebaseio.com/v0/topstories.json"
ITEM_URL = "https://hacker-news.firebaseio.com/v0/item/{}.json"


# 0 - top story
# 1 - most points from top 30
# 2 - most comments from top 30
# else - random from top 30
MODE = 0


def main():
    top_30 = http.get(TOP_STORIES_URL).json()[:30]

    if MODE == 0:
        index = 0
        story = get_story(top_30[index])
    elif MODE == 1:
        story = get_story_by(top_30, "score")
        index = top_30.index(story["id"])
    elif MODE == 2:
        story = get_story_by(top_30, "descendants")
        index = top_30.index(story["id"])
    else:
        index = int(random() * len(top_30))
        story = get_story(top_30[index])

    age = time.now() - time.fromtimestamp(int(story["time"]))
    if age.hours() != 0:
        pretty_age = "{} hrs ago".format(int(age.hours()))
    elif age.minutes() != 0:
        pretty_age = "{} mins ago".format(int(age.minutes()))
    else:
        pretty_age = "just now"

    title = story["title"]
    author = story["by"]
    num_points = story["score"]
    num_comments = story["descendants"]

    return render.Root(
        child=render.Stack(
            children=[
                render.Column(
                    children=[
                        render.Marquee(
                            render.Text("{}. {}".format(index + 1, title)),
                            width=64,
                        ),
                        render.Text("@" + author),
                        render.Text("{}p {}c".format(num_points, num_comments)),
                        render.Text(pretty_age),
                    ]
                ),
                render.Column(
                    expanded=True,
                    main_align="end",
                    children=[
                        render.Row(
                            expanded=True,
                            main_align="end",
                            children=[
                                render.Box(
                                    width=9,
                                    height=10,
                                    color="#b40",
                                    child=render.Text("Y", font="5x8"),
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    )


def get_story_by(ids, field):
    """Get the story with the largest value for the given field"""
    stories = [get_story(id_) for id_ in ids]
    story = stories[0]
    for other in stories[1:]:
        if other.get(field, 0) > story.get(field, 0):
            story = other
    return story


def get_story(id_):
    return http.get(ITEM_URL.format(int(id_))).json()


def random():
    """Return a pseudorandom number in [0, 1)"""
    return time.now().nanosecond() / 1000000000

import std/dom
import std/jsffi
import palladian
import std/jsfetch
import std/[asyncjs, jsconsole, jsheaders, jsformdata]


proc App():Component {.exportc.} =
  let (name, setName) = useState("")
  let (users {.exportc.}, setUsers) = useState(newJsObject())

  proc updateName(e:Event) {.exportc.} =
    setName(e.target.value)

  let isDisplay {.exportc.} = useMemo(proc():bool =
    return users.len > 0
  , @[users])

  useEffect(proc():CleanUpCallback =

    proc getCharactor() {.async.} =
      let url:cstring = "https://swapi.dev/api/people?search="
      let res = await fetch(url & name)
      let resJson = await res.json()
      setUsers(resJson["results"])

    discard getCharactor()

  , @[name])

  return html(fmt"""
    <input type="text" oninput=${updateName} class="w-full" placeholder="Type name" />
    <${Show} when=${isDisplay} fallback=${
      html`
        <p class="bg-pink-300 text-red-500 font-bold">Character not found</p>
      `
    }>
      <table>
        <thead>
          <tr>
            <th>name</th>
            <th>birth year</th>
          </tr>
        </thead>
        <tbody>
          <${For} each=${users}>
          ${user=>
            html`
              <tr>
                <td>${user.name}</td>
                <td>${user.birth_year}</td>
              </tr>
            `
          }
        <//>
        </tbody>
      </table>
    <//>
  """)

renderApp(App, document.getElementById("app"))

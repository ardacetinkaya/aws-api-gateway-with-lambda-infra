using Microsoft.AspNetCore.Mvc;

namespace HelloLambda.v2.Controllers;

[Route("api/[controller]")]
public class ValuesController : ControllerBase
{

    private readonly ILogger _logger;
    public ValuesController(ILogger logger){
        _logger = logger;
    }

    // GET api/values
    [HttpGet]
    public IEnumerable<string> Get()
    {
        return new string[] { "value1", "value2" };
    }

    // GET api/values/5
    [HttpGet("{id}")]
    public string Get(int id)
    {
        _logger.LogInformation("GET");
        return $"value-{id.ToString()}";
    }

    // POST api/values
    [HttpPost]
    public void Post([FromBody]string value)
    {

        _logger.LogInformation("POST");
        _logger.LogInformation($"Some data {value}");
    }

    // PUT api/values/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody]string value)
    {
    }

    // DELETE api/values/5
    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
}
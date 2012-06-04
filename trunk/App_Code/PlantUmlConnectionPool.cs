using System;
using System.Collections.Generic;
using System.Web;
using System.Threading;
using System.Diagnostics;

public static class PlantUmlConnectionPool
{
    private readonly static Queue<PlantUmlConnection> _connectionPool = new Queue<PlantUmlConnection>();
    private readonly static ManualResetEvent _availableEvent = new ManualResetEvent(false);

    public static PlantUmlConnection Get(TimeSpan timeout)
    {
        if (_connectionPool.Count == 0)
        {
            _availableEvent.Reset();
            if (_availableEvent.WaitOne(timeout))
            {
                return _connectionPool.Dequeue();
            }
            else
            {
                return null;
            }
        }
        else
        {
            lock (_connectionPool)
            {
                if (_connectionPool.Count == 0)
                    return null;
                else
                    return _connectionPool.Dequeue();                    
            }
        }
    }

    public static void Put(PlantUmlConnection connection)
    {
        lock (_connectionPool)
            _connectionPool.Enqueue(connection);
            
        _availableEvent.Set();
    }


    public static void Dispose()
    {
        while (_connectionPool.Count > 0)
        {
            var connection = _connectionPool.Dequeue();
            try
            {
                connection.Disconnect();
                connection.Dispose();
            }
            catch (Exception x)
            {
                Debug.WriteLine(x);
            }
        }
    }
}

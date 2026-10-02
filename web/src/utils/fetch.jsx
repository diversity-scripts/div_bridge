const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'div_bridge';

export async function post(eventName, data = {}) {
  try {
    const resp = await fetch(`https://${resourceName}/${eventName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify(data),
    });
    return await resp.json();
  } catch (e) {
    console.error(`div_bridge UI: Failed to post to ${eventName}`, e);
    return null;
  }
}
